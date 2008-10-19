! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces accessors math.order assocs kernel sequences
combinators make cpu.architecture compiler.cfg.instructions
compiler.cfg.instructions.syntax compiler.cfg.registers ;
IN: compiler.cfg.stack-frame

SYMBOL: frame-required?

SYMBOL: spill-counts

GENERIC: compute-stack-frame* ( insn -- )

: max-stack-frame ( frame1 frame2 -- frame3 )
    [ stack-frame new ] 2dip
        [ [ params>> ] bi@ max >>params ]
        [ [ return>> ] bi@ max >>return ]
        2bi ;

M: ##stack-frame compute-stack-frame*
    frame-required? on
    stack-frame>> stack-frame [ max-stack-frame ] change ;

M: _spill compute-stack-frame*
    drop frame-required? on ;

M: _spill-counts compute-stack-frame*
    counts>> stack-frame get (>>spill-counts) ;

M: insn compute-stack-frame* drop ;

: compute-stack-frame ( insns -- )
    frame-required? off
    T{ stack-frame } clone stack-frame set
    [ compute-stack-frame* ] each
    stack-frame get dup stack-frame-size >>total-size drop ;

GENERIC: insert-pro/epilogues* ( insn -- )

M: ##stack-frame insert-pro/epilogues* drop ;

M: ##prologue insert-pro/epilogues*
    drop frame-required? get [ stack-frame get _prologue ] when ;

M: ##epilogue insert-pro/epilogues*
    drop frame-required? get [ stack-frame get _epilogue ] when ;

M: insn insert-pro/epilogues* , ;

: insert-pro/epilogues ( insns -- insns )
    [ [ insert-pro/epilogues* ] each ] { } make ;

: build-stack-frame ( mr -- mr )
    [
        [
            [ compute-stack-frame ]
            [ insert-pro/epilogues ]
            bi
        ] change-instructions
    ] with-scope ;
