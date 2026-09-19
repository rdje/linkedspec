# Parse x and deliver two events only when the caller supplies a diagnostic sink.
Top::
 -> Hit { say("héllo 雪"); print("done"); return("ok") }

Hit:
 /x/
