# A successful x can precede a y that terminates parsing with a typed exception.
Top::
 -> Exit { say("before"); exit_now(7); say("unreachable") }
 -> Hit { return("ok") }

Exit:
 /y/

Hit:
 /x/
