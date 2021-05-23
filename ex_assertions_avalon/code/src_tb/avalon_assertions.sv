
/*
Simple Wait request (sect. 3.5.1)

"Quand le signal waitrequest est à 1, les données/contrôles envoyés par le maitre doivent rester stable"
property waitrequest_1;
   wait |-> $stable(exp);
endproperty

Attente Fixe (sect. 3.5.2)

Pipeline (sect. 3.5.3)

Burst (sect 3.5.4)

*/

module avalon_assertions #(
                           int AVALONMODE = 0,
                           int TESTCASE = 0,
                           int NBDATABYTES = 2,
                           int NBADDRBITS = 8,
                           int WRITEDELAY = 2,  // Delay for fixed delay write operation
                           int READDELAY = 1,   // Delay for fixed delay read operation
                           int FIXEDDELAY = 2)  // Delay for pipeline operation
   (
    input logic                     clk,
    input logic                     rst,

    input logic [NBADDRBITS-1:0]    address,
    input logic [NBDATABYTES:0]     byteenable,
    input logic [2^NBDATABYTES-1:0] readdata,
    input logic [2^NBDATABYTES-1:0] writedata,
    input logic                     read,
    input logic                     write,
    input logic                     waitrequest,
    input logic                     readdatavalid,
    input logic [7:0]               burstcount,
    input logic                     beginbursttransfer
    );


   // clocking block
   default clocking cb @(posedge clk);
   endclocking

   generate

      if (AVALONMODE == 0)
        begin : assert_waitrequest
           assert_waitreq1: assert property 
              (waitrequest |-> ($stable(address) and $stable(byteenable) and
                                 $stable(writedata) and $stable(read)));
        end

      if (AVALONMODE == 1)
        begin : assert_fixed
           assert1: assert property (!(read & write));
        end

      if (AVALONMODE == 2)
        begin : assert_pipeline_variable
           assert1: assert property (!(read & write));
        end

      if (AVALONMODE == 3)
        begin : assert_pipeline_fixed
           assert1: assert property (!(read & write));
        end

      if (AVALONMODE == 4)
        begin : assert_burst
           assert1: assert property (!(read & write));
        end

   endgenerate
endmodule
