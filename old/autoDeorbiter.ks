set messageBuffer to core:messages.

wait until ship:unpacked.

copypath("0:/deorbiter.ks", "deorbiter.ks").

wait until not messageBuffer:empty.
print "Starting deorbiter ".

set core:bootfilename to "deorbiter".
run "deorbiter".