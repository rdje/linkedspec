# A successful x can precede a y that terminates the input loop with typed exit.
Top::
 -> Exit { say("before"); exit_now(7); say("unreachable") }
 -> Hit { return("ok") }

Exit:
 /y/

Hit:
 /x/
