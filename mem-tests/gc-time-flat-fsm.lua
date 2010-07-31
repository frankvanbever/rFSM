-- test the static memory usage behavior of a fsm

require("rfsm")
require("time")
require("luagc")
--require("fsm2uml")
require("utils")
require("fsmbuilder")
require("rtposix")

rtposix.mlockall("MCL_BOTH")
rtposix.sched_setscheduler(0, "SCHED_FIFO", 99)

-- function () print(luagc.gcstat_tostring(luagc.timed_gc("collect"))) end
local progs = {
   entry=luagc.create_bench("step"),
--   doo = function (fsm, state, type)
-- 	    rtposix.nanosleep("REALTIME", "rel", 0, 1)
-- 	    -- print("sending e_trigger")
-- 	    -- rfsm.send_events(fsm, "e_trigger")
-- 	 end
}

-- create fsm
local fsm = rfsm.init(fsmbuilder.flat_chain_fsm(10, progs), "fsm_dyn_test")
assert(fsm, "fsm init failed")

-- fsm2uml.fsm2uml(fsm, "png", "fsm_dyn_test-uml.png")

-- perform full collect and stop gc
luagc.full()

for i=1,100000 do
   rfsm.step(fsm)
   rfsm.send_events(fsm, "e_trigger")
   rtposix.nanosleep("REALTIME", "rel", 0, 10000)
end

progs.entry("print_results")
