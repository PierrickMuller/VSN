/******************************************************************************
Project Math_computer

File : math_computer_tb.sv
Description : This module implements a test bench for a simple
              mathematic calculator.
              Currently it is far from being efficient nor useful.

Author : Y. Thoma
Team   : REDS institute

Date   : 13.04.2017

| Modifications |--------------------------------------------------------------
Ver    Date         Who    Description
1.0    13.04.2017   YTA    First version

******************************************************************************/

`include "math_computer_macros.sv"
`include "math_computer_itf.sv"
`include "math_computer_classes.sv"

module math_computer_tb#(integer testcase = 0,
                         integer errno = 0);

    // Déclaration et instanciation des deux interfaces
    math_computer_input_itf input_itf();
    math_computer_output_itf output_itf();

    // Déclaration classe valeurs d'entrées
    DutEntryConstraint in_values;

    // Seulement deux signaux
    logic      clk = 0;
    logic      rst;

    // instanciation du compteur
    math_computer dut(clk, rst, input_itf, output_itf);

    // génération de l'horloge
    always #5 clk = ~clk;

    // clocking block
    default clocking cb @(posedge clk);
        output #3ns rst,
               a            = input_itf.a,
               b            = input_itf.b,
               c            = input_itf.c,
               input_valid  = input_itf.valid,
               output_ready = output_itf.ready;
        input  input_ready  = input_itf.ready,
               result       = output_itf.result,
               output_valid = output_itf.valid;
    endclocking

    // coverage input
    covergroup cov_group_input;
        cov_a: coverpoint cb.a{
            bins under10 = {[0:9]};
            bins above10[`DATASIZE] = {[10:2 ** `DATASIZE]};
            bins other = default;
        }
        cov_b: coverpoint cb.b{
            bins parDataSize[`DATASIZE] = {[0:2 ** `DATASIZE]};
            bins other = default;
        }
        cov_c: coverpoint cb.c{
            bins under1000[10] = {[0:999]};
            bins above1000[`DATASIZE] = {[1000:2 ** `DATASIZE]};
            bins other = default;
        }
        cov_cross: cross cov_a,cov_b;
    endgroup

    //coverage output
    covergroup cov_group_output;
        cov_result: coverpoint cb.result;
    endgroup

    task test_case0();
        $display("Let's start first test case");
        cb.a <= 0;
        cb.b <= 0;
        cb.c <= 0;
        cb.input_valid  <= 0;
        cb.output_ready <= 0;

        ##1;
        // Le reset est appliqué 5 fois d'affilée
        repeat (5) begin
            cb.rst <= 1;
            ##1 cb.rst <= 0;
            ##10;
        end

        repeat (10) begin
            cb.input_valid <= 1;
            cb.a <= 1;
            ##1;
            ##($urandom_range(100));
            cb.output_ready <= 1;
        end
    endtask

    task test_case1();

        automatic cov_group_input cg_in = new();
        automatic cov_group_output cg_out = new();
        automatic int counter = 0;

        $display("Let's start second test case");
        cb.a <= 0;
        cb.b <= 0;
        cb.c <= 0;
        cb.input_valid  <= 0;
        cb.output_ready <= 0;
        in_values = new();
        ##1;
        // Le reset est appliqué 5 fois d'affilée
        //repeat (5) begin
        cb.rst <= 1;
        ##1 cb.rst <= 0;
        ##10;
        //end

        while(1) begin
            counter = counter + 1;
            cb.input_valid <= 1;
            assert (in_values.randomize) else $stop;
            $display("Value A : %d",in_values.a);
            $display("Value B : %d",in_values.b);
            $display("Value C : %d",in_values.c);
            cb.a <= in_values.a;
            cb.b <= in_values.b;
            cb.c <= in_values.c;
            cg_in.sample();
            ##1;
            if(cb.input_ready != 1)
                @(posedge cb.input_ready);
            cb.input_valid <= 0;
            cb.output_ready <= 1;
            ##1;
            if(cb.output_valid != 1)
                @(posedge cb.output_valid);
            cb.output_ready <= 0;
            $display("RESULT : %d",cb.result);
            cg_out.sample();
            //$display("Coverage in : %f out : %f full a : %f counter : ",cg_in.cov_a.get_inst_coverage(),cg_out.get_inst_coverage(),$get_coverage(),counter);
            cb.output_ready <= 1;
            
        end

    endtask

    task wait_for_coverage();
        do 
            @(posedge clk);
        while($get_coverage < 100);
    endtask;



    // Programme lancé au démarrage de la simulation
    program TestSuite;
        initial begin
            if (testcase == 0) begin
                test_case0();
                test_case1();
            end else if (testcase == 1) begin
                fork
                    test_case1();
                    wait_for_coverage();
                join_any
                disable fork;
            end else begin 
                $display("Ach, test case not yet implemented");
            end
            $display("done!");
            $stop;
        end
    endprogram

endmodule
