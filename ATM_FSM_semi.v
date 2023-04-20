module ATM_FSM_semi #(parameter in_size = 32,
                 parameter dis_size = 5,
                 parameter out_size = 32
                 )
    (
    input                       clk,
    input                       rst,

    input wire [in_size-1:0]    in_data,
    input wire                  in_valid,

    output reg [dis_size-1:0]   disp_sig,
    output reg                  data_valid,
    output reg [out_size-1:0]   out_data
);

//////sizes of User INFO\\\\\\\
localparam PIN_WIDTH        = 11,
           BALANCE_WIDTH    = 16,
           BANK_LIMIT_WIDTH = 14;

///////USER INFO\\\\\\\\\\\\\\
reg [PIN_WIDTH-1:0] PIN_reg;
reg [BALANCE_WIDTH-1:0] Balance;
reg [BANK_LIMIT_WIDTH-1:0] Bank_withdraw_Limit;  //daily

/////General Signals\\\\\\\\\
//reg language;
reg language_reg;
reg [in_size-1:0] account_no;
reg same_bank;
reg same_bank_reg;
wire done;
reg [2:0] enable;
reg [in_size-1:0] PIN_temp;
reg flag;
reg [2:0] timer;
reg timer_done;
reg timer_en;
reg timer_en_pin;
reg timer_en_with;
reg timer_en_inq;
reg timer_en_dep;
reg timer_en_main;
reg flag_same;


//////////  MAIN FSM \\\\\\\\\\
localparam  IDLE_main    =  3'b0,
            bank         =  3'b001,
            lang         =  3'b010,
            PIN          =  3'b011,
            option       =  3'b100, 
            anthr_op     =  3'b101,//another transaction
            card_exit    =  3'b110;

reg [2:0] main_state;
reg [2:0] main_next_state;

///////////// OPTIONS \\\\\\\\\\\
localparam MAIN            = 3'b000,
           WITHDRAW        = 3'b001,
           DEPOSIT         = 3'b010,
           BALANCE_INQUIRY = 3'b011,
           PIN_CHANGE      = 3'b100;

///////// Deposit \\\\\\\\\\
localparam IDLE_dep       = 3'b000,
           insert_cash    = 3'b001, //for fast cash
           confirm        = 3'b010,
           return_cash    = 3'b011,
           update_balance = 3'b100,
           finish_dep     = 3'b101; 
reg [2:0] dep_state;
reg [2:0] dep_next_state;
reg done_dep=0;
reg [9:0] cash_amount=0;
reg [14:0] account_balance='d50;


///////// Withdraw \\\\\\\\\\
localparam  IDLE_with     = 3'b0,
            diff_amount   = 3'b001, //for fast cash
            balance_limit = 3'b010,
            bank_limit    = 3'b011,
            receipt       = 3'b011,
            money_out     = 3'b100;

reg [2:0] with_state;
reg [2:0] with_next_state;

///////// Pin Change \\\\\\\\\\
localparam  IDLE_PIN     = 2'b00,
            ENTER_PIN    = 2'b01,
            RE_ENTER_PIN = 2'b10;

reg [1:0] pin_state;
reg [1:0] pin_next_state;
reg done_pin;
reg err_pin;

/////////disp sig\\\\\\\\\\\\\
reg [dis_size-1:0] disp_sig_with;
reg [dis_size-1:0] disp_sig_deposit;
reg [dis_size-1:0] disp_sig_Balance;
reg [dis_size-1:0] disp_sig_pin;
reg [dis_size-1:0] disp_sig_main;

/////OUTPUT\\\\\
reg [out_size-1:0] out_data_dep;
reg [out_size-1:0] out_data_inq;
reg [out_size-1:0] out_data_pin;
reg [out_size-1:0] out_data_with;
reg [out_size-1:0] out_data_main;



/////VALID\\\\\\
reg data_valid_with;
reg data_valid_dep;
reg data_valid_inq;
reg data_valid_pin;
reg data_valid_main;


/////////disp messages\\\\\
localparam Entry_msg                 = 5'b00000,
           Lang_Select_msg           = 5'b00001,
           Enter_Pin_msg             = 5'b00010,
           Select_Option_msg         = 5'b00011,
           Another_transaction_msg   = 5'b00100,
           TY_For_Your_Service_msg   = 5'b00101,  
           Inavlid_Pin_msg           = 5'b00110,   
           Enter_Cash_msg            = 5'b01000,
           Confirm_Amount_msg        = 5'b01001,  
           Pls_Take_Your_Cash_msg    = 5'b01010,
           Deposit_Accepted_msg      = 5'b01011,
           Current_Balance_msg       = 5'b01100,
           Transaction_Processed_msg = 5'b01101,
           Choose_with_or_Fast_msg   = 5'b01110,
           Enter_with_amount_msg     = 5'b01111,
           Enter_fast_amount_msg     = 5'b10000,
           Receipt_msg               = 5'b10001,
           WithDrawn_msg             = 5'b10010,
           WithDrawn_TAX_msg         = 5'b10011,
           Exceed_Balance_Limit_msg  = 5'b10100,
           Exceed_Bank_Limit_msg     = 5'b10101,
           Re_Enter_Pin_msg          = 5'b10111,
           Pin_Changed_msg           = 5'b11000,
           Enter_New_Pin_msg         = 5'b11001;



////////// Balance Inquiry \\\\\\\\\\
localparam IDLE_inq   = 3'b0,
           disp_balance = 3'b01, //0 no_receipt -- 1 receipt
           reciept_ask= 3'b10,
           reciept_out= 3'b11,
           finish_inq=3'b100;
           
reg [2:0] inq_state;
reg done_inq;
reg [2:0] inq_next_state;



always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
            begin
                main_state<=IDLE_main;
            end

        else
         begin
            main_state<=main_next_state;
         end
    end

always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
            
            pin_state<=IDLE_PIN;

        else
            pin_state<=pin_next_state;
    end


always @(posedge clk or negedge rst) 
    begin
          if (!rst) 
            
            dep_state<=IDLE_dep;

        else
            dep_state<=dep_next_state;       
    end




always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
            begin
                inq_state<=IDLE_inq;
            end
        else
            begin
                inq_state<=inq_next_state;
            end
    end



//////////////////MAIN FSM\\\\\\\\\\\\\\\\\

always @(*) 
    begin
        same_bank=0;
        timer_en_main=0;

        //language=0;
        case (main_state)
            IDLE_main:
                begin
                    disp_sig_main=Entry_msg;
                    data_valid_main=0;
                    out_data_main=0;
                    //done=0;
                    flag = 0;
                    timer_en_main=0;
                    enable=MAIN;
                    if (in_valid) 
                        begin
                           if(in_data[in_size-1:in_size-2]==2'b00)
                           begin
                            same_bank=1;    
                           end
                           else
                           begin
                            same_bank=0;
                           end
                           main_next_state=lang; 
                        end 
                    else
                        begin
                            main_next_state=IDLE_main;
                        end
                end
            lang:    
                begin
                    disp_sig_main = Lang_Select_msg; 
                    flag = 0;
                    enable=MAIN;
                    timer_en_main=0;
                    if(in_valid)
                        begin
                            //language=in_data[0];
                            data_valid_main=1; 
                            out_data_main=in_data[0];
                            main_next_state=PIN;
                        end
                    else
                        begin
                            data_valid_main=0;
                            out_data_main=0;
                            main_next_state=lang;
                        end
                end
            PIN:
                begin
                    disp_sig_main = Enter_Pin_msg; 
                    data_valid_main=0;
                    out_data_main=0;
                    flag = 0;
                    timer_en_main=0;
                    enable=MAIN;
                    if (in_valid)
                    begin
                        if (in_data[13:0]==14'd2000) 
                        begin
                            main_next_state=option;
                        end
                        else
                        begin
                            main_next_state=card_exit;
                            disp_sig_main = Inavlid_Pin_msg;//////////////note 
                        end
                    end
                    else
                    begin
                        main_next_state=PIN;
                    end
                end    
            option: 
                begin
                    disp_sig_main = Select_Option_msg; 
                    data_valid_main=0;
                    out_data_main=0;
                    flag = 0;
                    timer_en_main=0;
                    if (in_valid)
                        begin
                           enable=in_data[2:0];
                           main_next_state=anthr_op;
                           data_valid_main=0;
                           out_data_main=0;
                        end
                    else
                        begin
                           enable=MAIN;
                           main_next_state=option;
                        end
                end  
            anthr_op: 
                begin
                    if (done || flag)  
                        begin
                           flag = 1;
                           disp_sig_main = Another_transaction_msg;
                           data_valid_main=0;
                           out_data_main=0;
                           timer_en_main=0; 
                           enable=MAIN;

                           if (in_valid) 
                            begin
                                if (in_data==1) 
                                begin
                                    flag = 0;
                                    enable=MAIN;
                                    main_next_state=option;
                                end
                                else
                                    main_next_state=card_exit; ////swapping  card exit with anothr_op
                            end

                            else
                                begin
                                    main_next_state=anthr_op;
                                end
                        end
                    else
                    begin
                        disp_sig_main = Entry_msg; ////note:no select option msg here
                        data_valid_main=0;
                        out_data_main=0; 
                        main_next_state=anthr_op;
                        flag = 0;
                        
                    end
                end
            card_exit:
                begin
                    disp_sig_main = TY_For_Your_Service_msg; 
                    data_valid_main=0;
                    out_data_main=0; 
                    main_next_state=IDLE_main;
                    flag = 0;
                    timer_en_main=0;
                    enable=MAIN;
                end
        default:
            begin
                disp_sig_main = TY_For_Your_Service_msg; 
                data_valid_main=0;
                out_data_main=0; 
                main_next_state=IDLE_main;
                timer_en_main=0;
                flag = 0;
            end
        endcase
    end


//////////////////////////DEPOSIT FSM\\\\\\\\\\\\\\\\\\\\

always @(*) 
    begin

        case (dep_state)
            IDLE_dep: 
                 begin
                   //err_sig=0;
                    disp_sig_deposit='b0;
                    data_valid_dep=0;
                    out_data_dep=0;
                    done_dep=0;
                    timer_en_dep=0;
                    if (enable==DEPOSIT) 
                        begin
                            dep_next_state=insert_cash; 
                           
                        end 
                    else
                        begin
                            dep_next_state=IDLE_dep;
                        end
                end
            insert_cash:
                begin   
                    disp_sig_deposit=Enter_Cash_msg; //enter cash
                    data_valid_dep=0;
                    out_data_dep=0;
                    timer_en_dep=1; //enabling timer
                    if(timer_done)
                        begin
                            timer_en_dep=0; //disable timer
                            if(in_valid)
                                begin
                                    cash_amount=in_data;
                                    done_dep=0;
                                    dep_next_state=confirm;
                                end
                            else
                                begin
                                    done_dep=1;
                                    dep_next_state=IDLE_dep;
                                end
                    end
                    else
                        begin
                             done_dep=0;
                             dep_next_state=insert_cash;       
                        end
                end   
            confirm: 
                begin
                    disp_sig_deposit=Confirm_Amount_msg; // confrim amount
                    data_valid_dep=1; //valid signal high
                    out_data_dep=cash_amount; //write cash amount on output
                    timer_en_dep=0;
                   if(in_valid)
                   begin
                        
                        if(in_data=='b1) //confirm money
                            dep_next_state=update_balance;
                        else
                            dep_next_state=return_cash;

                   end
                   else 
                            dep_next_state=confirm;
                end      
            return_cash:
                begin
                    
                    disp_sig_deposit=Pls_Take_Your_Cash_msg; // please take your cash
                    data_valid_dep=1; //valid signal low
                    out_data_dep=cash_amount; //write cash amount on output
                    timer_en_dep=1; //enabling timer
                    if (timer_done) 
                        begin
                            timer_en_dep=0;
                            dep_next_state=insert_cash;        
                        end
                    else 
                        begin
                            dep_next_state=return_cash;
                        end
                end   
            update_balance:
                begin  
                    account_balance=account_balance+cash_amount;
                    disp_sig_deposit=0; // Your deposit has been accepted your balance =();
                    out_data_dep=account_balance; //write current balance on output
                    timer_en_dep=0; //enabling timer
                    data_valid_dep=0; //valid signal high
                    done_dep=0; //raise done signal
                    dep_next_state=finish_dep;        
                end
            finish_dep:
                begin
                    disp_sig_deposit=Deposit_Accepted_msg; // Your deposit has been accepted your balance =();
                    out_data_dep=account_balance; //write current balance on output
                    timer_en_dep=0; //enabling timer
                    data_valid_dep=1; //valid signal high
                    done_dep=1; //raise done signal
                    dep_next_state=IDLE_dep;        
                end
        default:
            begin
               // err_sig=0;
                disp_sig_deposit='b00; //Thank you for your service
                data_valid_dep=0;
                out_data_dep=0; 
                timer_en_dep=0; 
                dep_next_state=IDLE_dep;
            end
        endcase    
    end



///////////////////////BALANCE INQUIRY\\\\\\\\\\

always @(*) 
    begin
        case (inq_state)
            IDLE_inq   :
                begin
                    disp_sig_Balance=Entry_msg;
                    data_valid_inq=0;
                    out_data_inq=0;
                    done_inq=0;
                   timer_en_inq=0; 
                     if (enable == BALANCE_INQUIRY)
                        begin
                            inq_next_state = disp_balance;
                        end
                        else
                        begin
                            inq_next_state = IDLE_inq;
                        end
                       

                end
            disp_balance :
                begin
                    disp_sig_Balance=Current_Balance_msg; // confrim amount
                    data_valid_inq=1; //valid signal high
                    out_data_inq=account_balance; //write balacne on output
                    done_inq=0;
                    inq_next_state=reciept_ask;
                end
            reciept_ask:
                begin
                    disp_sig_Balance=Receipt_msg; 
                    data_valid_inq=0; 
                    out_data_inq=0; 
                    timer_en_inq=0;
                   if(in_valid)
                   begin
                        
                        if(in_data=='b1) //confirm reciept
                            begin
                                inq_next_state=reciept_out;
                                done_inq=0;

                            end
                        else
                            begin
                                inq_next_state=finish_inq;
                                done_inq=1;
                            end

                   end
                   else 
                            inq_next_state=reciept_ask;
                end
            reciept_out:
                begin
                    disp_sig_Balance=Transaction_Processed_msg; //enter cash
                    data_valid_inq=1;
                    out_data_inq=account_balance;

                    timer_en_inq=1; //enabling timer
                    if(timer_done)
                        begin
                            timer_en_pin=0; //disable timer
                            inq_next_state=finish_inq;
                            done_inq=1;
                        
                    end
                    else
                        begin
                             done_inq=0;
                             inq_next_state=reciept_out;       
                        end
                end
            finish_inq:
                begin
                    inq_next_state=IDLE_inq;
                    done_inq=1;
                    disp_sig_Balance=0; //enter cash
                    data_valid_inq=0;
                    out_data_inq=0;
                    timer_en_inq=0;

                     
                end

            default:
                begin
                    disp_sig_deposit=Entry_msg; // confrim amount
                    data_valid_inq=0; //valid signal high
                    out_data_inq=0; //write balacne on output
                    done_inq=0;
                    timer_en_inq=0;
                    inq_next_state=IDLE_inq; 
                end 
        endcase        
    end


///////////PIN CHANGE FSM \\\\\\\\\\\\
always@(*)
begin
    out_data_pin=0;
    data_valid_pin=0;
    case (pin_state)
    IDLE_PIN    :
    begin
        if (enable == PIN_CHANGE)
        begin
            pin_next_state = ENTER_PIN;
        end
        else
        begin
            pin_next_state = IDLE_PIN;
        end
        err_pin        = 0;
        disp_sig_pin   = Select_Option_msg; 
        done_pin       = 0;
        timer_en_pin = 0;
    end
    ENTER_PIN   :
    begin
        err_pin        = 0;
        done_pin       = 0;
        timer_en_pin = 0;
        if (in_valid)
        begin
            pin_next_state = RE_ENTER_PIN;
            disp_sig_pin   = Re_Enter_Pin_msg;
            
        end
        else
        begin
            pin_next_state = ENTER_PIN;
            disp_sig_pin   = Enter_Pin_msg;
        end
    end
    RE_ENTER_PIN:
    begin
        if (in_valid || timer_en_pin)
        begin 
            if (in_data == PIN_temp)
            begin
                pin_next_state = RE_ENTER_PIN;
                err_pin        = 0;
                disp_sig_pin   = Transaction_Processed_msg;
                done_pin       = 0; 
                timer_en_pin   = 1; 
                if (timer_done)
                begin
                    pin_next_state = IDLE_PIN;
                    err_pin        = 0;
                    disp_sig_pin   = Pin_Changed_msg;
                    done_pin       = 1; 
                    timer_en_pin = 0;
                end
                else
                begin
                    pin_next_state = RE_ENTER_PIN;
                    err_pin        = 0;
                    disp_sig_pin   = Transaction_Processed_msg;
                    done_pin       = 0; 
                    timer_en_pin = 1;
                end
            end
            else
            begin
                pin_next_state = ENTER_PIN;
                err_pin        = 0;
                disp_sig_pin   = Inavlid_Pin_msg;
                done_pin       = 0; 
                timer_en_pin = 0; 
            end
        end
        else
        begin
            pin_next_state = RE_ENTER_PIN;
            err_pin        = 0;
            disp_sig_pin   = Re_Enter_Pin_msg;
            done_pin       = 0; 
            timer_en_pin = 0;
        end
    end
    default:
    begin
        pin_next_state = pin_next_state;
        err_pin        = 0;
        disp_sig_pin   = disp_sig_pin;
        done_pin       = 0;  
        timer_en_pin = 0;
    end
    endcase
end




////////Timer \\\\\\\\\\
always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
            begin
                timer<=0;
                timer_done<=0;
            end
        else
           begin
                
            if(timer_en)
                begin
                    if (timer==7) 
                        begin
                            timer_done<=1;
                            timer<=0;
                        end
                    else
                        begin
                            timer<=timer+1; 
                            timer_done<=0;

                        end
                end
            else
                begin
                    timer<=0; 
                    timer_done<=0;
                end
            end
    end

//assign timer_en = timer_en_pin;
assign done=((done_dep)|(done_inq)|(done_pin));



always @(*) 
begin
    case(enable)
    WITHDRAW       : out_data = out_data_with;
    DEPOSIT        : out_data = out_data_dep;
    BALANCE_INQUIRY: out_data = out_data_inq;
    PIN_CHANGE     : out_data = out_data_pin;
    MAIN           : out_data = out_data_main;
    default        : out_data = out_data_main;
    endcase    
end

always @(*) 
begin
    case(enable)
    WITHDRAW       : disp_sig = disp_sig_with;
    DEPOSIT        : disp_sig = disp_sig_deposit;
    BALANCE_INQUIRY: disp_sig = disp_sig_Balance;
    PIN_CHANGE     : disp_sig = disp_sig_pin;
    MAIN           : disp_sig = disp_sig_main;
    default        : disp_sig = disp_sig_main;
    endcase    
end

always @(*) 
begin
    case(enable)
    WITHDRAW       : data_valid = data_valid_with;
    DEPOSIT        : data_valid = data_valid_dep;
    BALANCE_INQUIRY: data_valid = data_valid_inq;
    PIN_CHANGE     : data_valid = data_valid_pin;
    MAIN           : data_valid = data_valid_main;
    default        : data_valid = data_valid_main;
    endcase    
end

always @(*) 
begin
    case(enable)
    WITHDRAW       : timer_en = timer_en_with;
    DEPOSIT        : timer_en = timer_en_dep;
    BALANCE_INQUIRY: timer_en = timer_en_inq;
    PIN_CHANGE     : timer_en = timer_en_pin;
    MAIN           : timer_en = timer_en_main;
    default        : timer_en = timer_en_main;
    endcase    
end

always @(posedge clk or negedge rst) 
begin
    if(!rst)
    begin
        same_bank_reg <= 0;
    end
    else
    begin
        if((main_state==IDLE_main) &&(in_valid))
           same_bank_reg <= same_bank; 
        else
           same_bank_reg<=same_bank_reg;   
end
end

///////unused register and can be rsolved\\\\\ byt removing language var
/*
always @(posedge clk or negedge rst) 
begin
    if(!rst)
    begin
        language_reg <= 0;
    end
    else
    begin
        if (language)
        begin
            language_reg <= 1;
        end
        else
        begin
            language_reg <= language_reg;
        end
    end
end*/

always @(posedge clk or negedge rst) 
begin
    if(!rst)
    begin
        PIN_temp <= 0;
    end
    else
    begin
        if ((enable == PIN_CHANGE)&&(in_valid)&&(pin_state == ENTER_PIN))
        begin
            PIN_temp <= in_data;
        end
        else
        begin
            PIN_temp <= PIN_temp;
        end
    end
end

endmodule