! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors arrays kernel sequences namespaces words
math compiler.cfg.registers compiler.cfg.instructions.syntax ;
IN: compiler.cfg.instructions

! Virtual CPU instructions, used by CFG and machine IRs

TUPLE: ##cond-branch < insn { src vreg } ;
TUPLE: ##unary < insn { dst vreg } { src vreg } ;
TUPLE: ##nullary < insn { dst vreg } ;

! Stack operations
INSN: ##load-literal < ##nullary obj ;
INSN: ##peek < ##nullary { loc loc } ;
INSN: ##replace { src vreg } { loc loc } ;
INSN: ##inc-d { n integer } ;
INSN: ##inc-r { n integer } ;

! Subroutine calls
TUPLE: stack-frame
{ params integer }
{ return integer }
{ total-size integer }
spill-counts ;

INSN: ##stack-frame stack-frame ;
 : ##simple-stack-frame ( -- ) T{ stack-frame } ##stack-frame ;
INSN: ##call word ;
INSN: ##jump word ;
INSN: ##return ;

INSN: ##intrinsic quot defs-vregs uses-vregs ;

! Jump tables
INSN: ##dispatch src temp ;
INSN: ##dispatch-label label ;

! Boxing and unboxing
INSN: ##copy < ##unary ;
INSN: ##copy-float < ##unary ;
INSN: ##unbox-float < ##unary ;
INSN: ##unbox-f < ##unary ;
INSN: ##unbox-alien < ##unary ;
INSN: ##unbox-byte-array < ##unary ;
INSN: ##unbox-any-c-ptr < ##unary ;
INSN: ##box-float < ##unary { temp vreg } ;
INSN: ##box-alien < ##unary { temp vreg } ;

! Memory allocation
INSN: ##allot < ##nullary size type tag { temp vreg } ;
INSN: ##write-barrier { src vreg } card# table ;
INSN: ##gc ;

! FFI
INSN: ##alien-invoke params ;
INSN: ##alien-indirect params ;
INSN: ##alien-callback params ;
INSN: ##callback-return params ;

GENERIC: defs-vregs ( insn -- seq )
GENERIC: uses-vregs ( insn -- seq )

M: ##nullary defs-vregs dst>> 1array ;
M: ##unary defs-vregs dst>> 1array ;
M: ##write-barrier defs-vregs
    [ card#>> ] [ table>> ] bi 2array ;

: allot-defs-vregs ( insn -- seq )
    [ dst>> ] [ temp>> ] bi 2array ;

M: ##box-float defs-vregs allot-defs-vregs ;
M: ##box-alien defs-vregs allot-defs-vregs ;
M: ##allot defs-vregs allot-defs-vregs ;
M: ##dispatch defs-vregs temp>> 1array ;
M: insn defs-vregs drop f ;

M: ##replace uses-vregs src>> 1array ;
M: ##unary uses-vregs src>> 1array ;
M: ##write-barrier uses-vregs src>> 1array ;
M: ##dispatch uses-vregs src>> 1array ;
M: insn uses-vregs drop f ;

: intrinsic-vregs ( assoc -- seq' )
    [ nip dup vreg? swap and ] { } assoc>map sift ;

: intrinsic-defs-vregs ( insn -- seq )
    defs-vregs>> intrinsic-vregs ;

: intrinsic-uses-vregs ( insn -- seq )
    uses-vregs>> intrinsic-vregs ;

M: ##intrinsic defs-vregs intrinsic-defs-vregs ;
M: ##intrinsic uses-vregs intrinsic-uses-vregs ;

! Instructions used by CFG IR only.
INSN: ##prologue ;
INSN: ##epilogue ;

INSN: ##branch ;
INSN: ##branch-f < ##cond-branch ;
INSN: ##branch-t < ##cond-branch ;
INSN: ##if-intrinsic quot defs-vregs uses-vregs ;

M: ##cond-branch uses-vregs src>> 1array ;

M: ##if-intrinsic defs-vregs intrinsic-defs-vregs ;
M: ##if-intrinsic uses-vregs intrinsic-uses-vregs ;

! Instructions used by machine IR only.
INSN: _prologue stack-frame ;
INSN: _epilogue stack-frame ;

INSN: _label id ;

TUPLE: _cond-branch < insn { src vreg } label ;

INSN: _branch label ;
INSN: _branch-f < _cond-branch ;
INSN: _branch-t < _cond-branch ;
INSN: _if-intrinsic label quot defs-vregs uses-vregs ;

M: _cond-branch uses-vregs src>> 1array ;

M: _if-intrinsic defs-vregs intrinsic-defs-vregs ;
M: _if-intrinsic uses-vregs intrinsic-uses-vregs ;

! These instructions operate on machine registers and not
! virtual registers
INSN: _spill src class n ;
INSN: _reload dst class n ;
INSN: _spill-counts counts ;
