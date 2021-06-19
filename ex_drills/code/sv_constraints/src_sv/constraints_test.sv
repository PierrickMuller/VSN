class constraints_class;
    rand logic wr;
    rand logic rd;
    rand logic cs;
    rand logic[1:0] typee;
    rand logic[7:0] address;
    rand logic[31:0] data;
    rand logic parity;

    constraint t{
        (cs == 0) -> address <= 0;
        
        (wr == 1) -> rd <= 0;
        (rd == 1) -> wr <= 0;

        (typee == 0) -> address inside {[0:15]};
        (typee == 1) -> address inside {[16:127]};
        (typee == 2) -> address inside {[128:(2**8-1)]};

        (($countones(data) % 2) == 0) -> parity <= 1;
        (($countones(data) % 2) != 0) -> parity <= 0;
    }

endclass : constraints_class


module constraints_test;

    task test_case1();
        automatic constraints_class obj = new();


        $display("Let's start test 1");

        for(int i=0;i<100;i++)
        begin
            void'(obj.randomize());
            $display("cs = %d, wr = %d, rd = %d, typee = %d, address = %d, data = %d, parity = %d",
                obj.cs, obj.wr, obj.rd, obj.typee, obj.address, obj.data, obj.parity);
        end
        $display("End of test 1");


    endtask


    // Programme lancé au démarrage de la simulation
    program TestSuite;
        initial begin
            test_case1();
            $display("done!");
            $stop;
        end
    endprogram

endmodule : constraints_test
