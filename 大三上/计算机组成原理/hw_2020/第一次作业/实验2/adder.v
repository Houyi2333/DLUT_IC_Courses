module floatadd(ix, iy, clk, a_en, ost,oz);

      //32???? ix+iy=oz

      //  ????31???????30~23???????????22~0?????23??=32????

      //ix=xm*2^xe      iy=ym*2^ye

      //  

   input ix, iy, clk, a_en;  //clk--???a_en---???

   output oz, ost;//ost???????

   wire[15:0] ix,iy;

   reg[15:0] oz;

   wire   clk,ost,a_en;

   reg[12:0]    xm, ym, zm;  //?????26??1???+2?????+23???

   reg[4:0]     xe, ye, ze;  //????8??

   reg[2:0] state; //????

   parameter   start=3'b000,zerock=3'b001,exequal=3'b010,addm=3'b011,infifl=3'b100,over =3'b101;           

   assign ost = (state == over) ? 1 : 0;        

   always@(posedge ost) //??????

   begin

      if(a_en)

   oz <= {zm[12],ze[4:0],zm[9:0]};  // ???????32??????zm[25]????

   end                                 

   always@(posedge clk)                //????start->zerock->exequal->addm->infifl->over

        begin 

   case(state)

start:        //???????????????????

  begin 

xe <= ix[14:10];//ix???8??

xm <= {ix[15],1'b0,1'b1,ix[9:0]};//ix??=???+01+22???

ye <= iy[14:10];//iy??

ym <= {iy[15],1'b0,1'b1,iy[9:0]};//iy??

state <= zerock;//????

   end

zerock: 

   begin 

if(ix == 0)//??ix=0????oz=iy

begin   

   {ze, zm} <= {ye, ym};

   state <= over;//???

end

else

if(iy == 0)  //??iy=0????oz=ix

begin

   {ze, zm} <= {xe, xm};

 state <= over;

end

else

state <= exequal;

   end

exequal:           //???????????

   begin 

 if(xe == ye)//???????????????

state <= addm;  //?????

 else 

if(xe > ye)

 begin

ye <= ye + 1;     //iy?????      

ym[11:0] <= {1'b0, ym[11:1]}; //iy???????

if(ym == 0)  //????ym?0????????0??

begin

zm <= xm;

ze <= xe;

state <= over;

end

else

 state <= exequal;//??????

 end

else      //xe

 begin

xe <= xe + 1;   //ix?????               

xm[11:0] <= {1'b0,xm[11:1]};  //ix???????

if(xm == 0)   //????xm?0????????0?

 begin

zm <= ym;

ze <= ye;

state <= over;

 end

else

state <= exequal;//??????

        end

    end

addm:        //??????????????

  begin 

if ((xm[12]^ym[12])==0) //?25????????????

  begin

      zm[12] <= xm[12];

      zm[11:0] <= xm[11:0]+ym[11:0]; //????

  end

else                   //????????????

   if(xm[11:0]>ym[11:0])  //xm>ym,

      begin

          zm[12] <= xm[12]; 

          zm[11:0] <=xm[11:0]-ym[11:0];  //?????

          end

       else             //xm

          begin

          zm[12] <= ym[12];

          zm[11:0] <=ym[11:0]-xm[11:0];           

          end    

 ze <= xe;

 state <= infifl;

  end

infifl:                   //???????

  begin 

if(zm[11]==1)    //???????1

   begin

     zm[11:0] <= {1'b0,zm[11:1]};     //?????????????????

     ze <= ze + 1;   //??????

     state <= over;  

   end

else

if(zm[10]==0)   //?????23??0

 begin

           zm[11:0] <= {zm[10:0],1'b0};  //?????????????????

           ze <= ze - 1;  //??????  

           state <= infifl;    //???????????

         end

       else

           state <= over;

 end

 over:

begin 

      state<= start; //?????? 

end

 default:

begin

     state<= start;

end

endcase

 end

endmodule