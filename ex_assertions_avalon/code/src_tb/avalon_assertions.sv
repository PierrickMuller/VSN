
/*
Simple Wait request (sect. 3.5.1)

- Quand le signal waitrequest est à 1, les données/contrôles envoyés par le maitre doivent rester stable

Attente Fixe (sect. 3.5.2)



Pipeline (sect. 3.5.3)
variable : 
- L'adresse doit rester stable lors d'un waitrequest
- Si un waitrequest est observé, alors readdatavalid doit être activé au moins une fois par la suite
- Le nombre de cycle ou readdatavalid est à 1 doit toujours être inférieur ou égal au nombre de cycles
de read - le nombre de cycles ou waitrequest est actif.

fixed : 
- readdatvalid doit être à 1 X cycles après la fin de la phase d'adresse (FIXEDDELAY)
- L'adresse doit rester stable lors d'un waitrequest
- Si un waitrequest est observé, alors readdatavalid doit être activé au moins une fois par la suite
- Le nombre de cycle ou readdatavalid est à 1 doit toujours être inférieur ou égal au nombre de cycles
de read - le nombre de cycles ou waitrequest est actif.

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

   //Permet de tester l'assertion 3
   int nb_cycle_read = 0;
   int nb_rdatavalid = 0;

   always @(posedge clk)
      begin
         if(read)
            if(!waitrequest)
               nb_cycle_read = nb_cycle_read + 1;
         if(readdatavalid)
            nb_rdatavalid = nb_rdatavalid + 1;
      end

   property adress_stable_pipeline;
      ( waitrequest and ($past(waitrequest)) |-> $stable(address));
   endproperty

   property assert_rdatavalid_after_waitrequest_pipeline;
      ((!(waitrequest) and ($past(waitrequest)) |-> ##[1:$] $rose(readdatavalid)));
   endproperty

   property assert_nb_rdatavalid_pipeline;
      (
               @(posedge clk)
               (nb_rdatavalid <= nb_cycle_read));
   endproperty

   generate

      if (AVALONMODE == 0)
        begin : assert_waitrequest
           assert_waitreq1: assert property 
              ($stable(waitrequest) and waitrequest |-> ($stable(address) and $stable(byteenable) 
                                                      and $stable(read) and $stable(write)));
        end

      if (AVALONMODE == 1)
        begin : assert_fixed
           assert_fix1: assert property 
              ($rose(read) |=> ($stable(address) and $stable(byteenable) 
                                 and $stable(read) and $stable(write)
                        throughout (read[*READDELAY]) ) );
           assert_fix2: assert property 
              ($rose(write) |=> ($stable(address) and $stable(byteenable) 
                                 and $stable(read) and $stable(write)
                        throughout (write[*WRITEDELAY]) ) );

        end

      if (AVALONMODE == 2)
        begin : assert_pipeline_variable
           assert_adress_stable: assert property 
              (adress_stable_pipeline);

           assert_rdatavalid_after_waitrequest: assert property
              //fell detecte un flanc descendant de waitrequest au début du programme 
              //($fell(waitrequest) |=> ...);
              (assert_rdatavalid_after_waitrequest_pipeline);
            
           assert_nb_rdatavalid: assert property 
              (assert_nb_rdatavalid_pipeline);

        end

      if (AVALONMODE == 3)
        begin : assert_pipeline_fixed
           assert_fixed_delay: assert property 
              (read and !(waitrequest) |-> ##(FIXEDDELAY) readdatavalid);

           assert_adress_stable: assert property 
              (adress_stable_pipeline);

           assert_rdatavalid_after_waitrequest: assert property
              //fell detecte un flanc descendant de waitrequest au début du programme 
              //($fell(waitrequest) |=> ...);
              (assert_rdatavalid_after_waitrequest_pipeline);
            
           assert_nb_rdatavalid: assert property 
              (assert_nb_rdatavalid_pipeline);
        end

      if (AVALONMODE == 4)
        begin : assert_burst
           assert1: assert property (!(read & write));
        end

   endgenerate
endmodule
