:- module(gvar_syntax,[('.')/2,gvar_ref/1]).

/** <module> gvar_syntax - Global Variable Syntax

    Author:        Douglas R. Miles
    E-mail:        logicmoo@gmail.com
    WWW:           http://www.logicmoo.org
    Copyright (C): 2017
                       
    This program is free software; you can redistribute it and/or
    modify it.

*/
gvar_ref(_).

gvar_ref(Name,Value):- nb_current(Name,Ref),!,Ref=Value, nonvar(Value)->true;freeze(Value,set_gvar(Name, Value)).
gvar_ref(Name,Value):- nb_linkval(Name,Value),freeze(Value,set_gvar(Name, Value)).

set_gvar(Name,Value):- nb_linkval(Name,Value).

gvar_type(gvar_default_type,nb_linkval).


% Call Previous Method
gv_call(Self,Memb,Value):- notrace(var(Self);is_dict(Self))
 ->'$dict_dot3'(Self, Memb, Value)
 ; once((arg(1,Self,Name),gv_call0(Name,Memb,Value))).



gv_call0(gvar,Name,Value):-gvar_ref(Name,Value).

gv_call0(Name, current(),Value):-nb_current(Name,Value).
gv_call0(Name, get(),Value):-nb_getval(Name,Value).
gv_call0(Name, value, Value):- gvar_ref(Name,Value).

gv_call0(Name, clear(),gvar_ref(Name)):- nb_delete(Name).

gv_call0(Name, set, Value):- nb_setval(Name,Value).
gv_call0(Name, let, Value):- b_setval(Name,Value),nb_linkval(Name,Value).
gv_call0(Name, set(Value),gvar_ref(Name)):- gv_call0(Name, set, Value).
gv_call0(Name, let(Value),gvar_ref(Name)):- gv_call0(Name, let, Value).


% :- trace.
:- Head=..['.',Name, Func], system:asserta(( Head :- gv_call(Name,Func,_))).


:- if(clause('$dicts':'.'(_,_,_),_)).

:- clause('$dicts':'.'(Dict, Func, Value),BODY),
   asserta(('$dict_dot3'(Dict, Func, Value):- '$dict':BODY)).

:- else.

'$dict_dot3'(Dict, Func, Value) :-
    (   '$get_dict_ex'(Func, Dict, V0)
    *-> Value = V0
    ;   is_dict(Dict, Tag)
    ->  '$dicts':eval_dict_function(Func, Tag, Dict, Value)
    ;   is_list(Dict)
    ->  (   (atomic(Func) ; var(Func))
        ->  dict_create(Dict, _, Dict),
            '$get_dict_ex'(Func, Dict, Value)
        ;   '$type_error'(atom, Func)
        )
    ;   '$type_error'(dict, Dict)
    ).

:- endif.


:- redefine_system_predicate('system':'.'(_Dict, _Func, _Value)).

:- 'system':abolish('$dicts':'.'/3).

'system':'.'(Dict, Func, Value) :- gv_call(Dict,Func,Value).



