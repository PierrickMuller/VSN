`include "math_computer_macros.sv"

class DutEntry;
    rand logic[`DATASIZE-1:0] a;
    rand logic[`DATASIZE-1:0] b;
    rand logic[`DATASIZE-1:0] c;
    rand bit helper_a;
endclass : DutEntry

class DutEntryConstraint extends DutEntry;
    constraint valuesConstraint {
        (helper_a == 1) -> a inside{[0:9]};
        (helper_a == 0) -> a inside{[10:2 ** `DATASIZE]};
        (a > b) -> c inside {[0:999]};
        //(a[0] == 0 ) -> b[0] inside {1};
        a[0] || b[0];
    }
    constraint AResolve {
        helper_a dist {
            1'b0 := 1,
            1'b1 := 1
        };
    }
    constraint order {
        solve helper_a before b;
        solve a before b;
        solve b before c;
    }
endclass : DutEntryConstraint