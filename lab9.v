/////////// AUTHOUR DHRUV DHAWAN
module lab9 (clk,car,car_on_sec,ped_cross,lit,ped,reset,GPIO_0);

  input clk,reset,car_on_sec,ped_cross;
  output reg [8:0]lit;
  output [1:0] GPIO_0;
  output reg ped,car;
  reg [2:0] state;
  reg [2:0]cnt;
  reg [25:0]cntclk;
  reg cntsec;
  assign GPIO_0[0] =car_on_sec;
assign GPIO_0[1] = lit[3];

  parameter t_yellow = 3'b010;  // 3 sec (gt being used)
  parameter t_sec = 3'b101; // 6 sec (gteq being used)
  parameter S0 = 3'b000;
  parameter S1 = 3'b001;
  parameter S2 = 3'b010;
  parameter S3 = 3'b011;
  parameter S4 = 3'b100;
  parameter S5 = 3'b101;
  parameter S6 = 3'b110;
  parameter S7 = 3'b111;

      always @ (posedge clk)
		begin
        if (cntclk ==26'd50000000) // 26'd5000000 /////// 26'd50000000 for qsim change
        begin
          cntsec <= 1;
          cntclk <= 26'b0;
        end
        else
        begin
          cntsec <= 0 ;
          cntclk <= cntclk + 26'b1;
        end
      end

      always @ (*)
		begin  // hold val for ped
        if (~ped_cross) 
        begin
          ped <= 1;
        end
        else if(state == S6)
        begin
          ped <= 0 ;
        end
      end
		//


      always @ (*)
		begin  // hold val for car
          if (~car_on_sec) 
          begin
            car <= 1;
          end
          else if(state == S3)
          begin
            car<=0 ;
          end
        end
		  //

        always @ (posedge cntsec)
		  begin
            if (reset) 
            begin
              state <= S0;
              cnt <= 0;
            end else
            begin
              case (state)
                    S0:begin // green light hwy
									lit <= 9'b001100100;
                          if (car_on_sec)
                          begin
                            state <= S1;
                          end
                          if (ped)
                          begin
                            state <= S4;
                          end
                      end
							 
                      S1:begin // yellow light hwy to s2
                            lit <= 9'b010100100;//hwy,xing,ped
                            if (cnt > t_yellow)
                            begin
                              state <= S2;
                              cnt<=0;
                            end
                            else begin
                              state <= S1;
                              cnt <= cnt + 1;
                            end
                        end
							
                        S2:begin// green light sec xing acr to go
                          lit <= 9'b100001100;
                          if (cnt > t_sec)
                          begin
                            state <= S3;
                            cnt <= 0;
                          end
                          else if((cnt > t_yellow)&(~car_on_sec)) begin
                            state <=S3;
                            cnt <= 0;
                          end
                          else begin
                            state <= S2;
                            cnt<= cnt+1;
                          end
                        end

                        S3:begin // yellow for sec lit
                          lit <= 9'b100010100;
                          if(cnt > t_yellow)
								  begin
                            state <= S7;
                            cnt <= 0;
                          end
                          else 
								  begin
                            state <= S3;
                            cnt <= cnt + 1;
                          end
                        end
                        S4:begin // same as s1
                          lit <= 9'b010100100;
                          if (cnt > t_yellow)begin
                            state <= S5;
                            cnt <= 0;
                          end
                          else 
								  begin
                            state <= S4;
                            cnt <= cnt + 1;
                          end
                        end
                        S5:begin // ped green
                          lit <= 9'b100100001;
                          if(cnt > t_sec)
                          begin
                            state <= S6;
                            cnt <= 0;
                          end
                          else
								  begin
                            state <= S5;
                            cnt <= cnt + 1;
                          end
                        end
                        S6: begin // ped yellow/amber
                          lit <= 9'b100100010;
                          if (cnt > t_yellow)
                          begin
                            state <= S7;
                            cnt <= 0;
                          end
                          else 
								  begin
                            state <= S6;
                            cnt <= cnt+1;
                          end
                        end

                        S7: begin // same as s0 
                          lit <= 9'b001100100;
                          if (cnt > t_sec)
                          begin
                            state <= S0;
                            cnt <= 0;
                          end
                          else
								  begin
                            state <= S7;
                            cnt <= cnt+1;
                          end
                        end
                        //default state<=S0;
                  endcase
            end
        end

endmodule