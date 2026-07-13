Top::
 /x/ -> Done { scores += 1; scores += 5; scores += 3; scores += 5; return(array(scores.sum(), scores.avg(), scores.median(), scores.range(), scores.min(), scores.max(), scores.sorted().take(3).avg(), scores.uniq().sum(), num_min(scores), num_max(scores), min(scores), max(scores))) }

Done::
 /[a-z]+/
