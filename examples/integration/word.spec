# Collect ASCII words from one input. Other text is skipped.
Top::
 -> Word .push
 LX { return(copy(Top)) }

Word:
 /([A-Za-z]+)/
 I { return(entry_group(0)) }
