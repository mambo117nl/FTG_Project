CREATE OR REPLACE PACKAGE FPT_CHECK_SONUM_PUB_V1  AS
/* $Header: FPT_CHECK_SONUM_PUB_V1.pls 120.3 2005/07/19 18:56:53 repuri ship$ */
/*#
 * Sale Order check  API
 * This API contains the procedures to  Sales record.
 * @rep:scope public
 * @rep:product GL
 * @rep:displayname SalesOrder Check All API
 * @rep:category BUSINESS_ENTITY FPT_CHECK_SO

*/
  /*****************************************************************************************
   This is a public API that caller will invoke. 
   It provides procedures for managing Salesreps, like
   create and update Sales from other modules.
   Its main procedures are as following:
   fpt_check_sale_order_all
   ******************************************************************************************/

TYPE SO_number_rec_all_type IS RECORD (    
    
    ddp_request_code             VARCHAR2(100),    
    org_id             NUMBER,    
    Order_number           oe_order_headers_all.order_number%type
);

TYPE SO_number_tbl_all IS TABLE OF SO_number_rec_all_type INDEX BY BINARY_INTEGER;


TYPE SO_number_Rec_Type_out IS RECORD
  (
   x_ddp_request_code        VARCHAR2(100),    
   x_message              varchar2(1000)
   );
   
TYPE SO_number_tbl_out IS TABLE OF SO_number_Rec_Type_out INDEX BY BINARY_INTEGER;

/* Procedure to create the batch Salesreps All 
  based on input values passed by calling routines. */
/*#
 * Create Sales batch All API   
 * This procedure allows the user to create a salesrep record.
 * @param p_DDP_ID batch ID. 
 * @param P_SO_number_tbl_all P_SO_number_tbl_all record.
 
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @param x_msg_data A character string containing message text.
 * Refer to the package description above for more information
 * about this parameter and a list of valid values.
 * @param P_SO_number_tbl_out Sales message record out.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname SalesOrder Check All API
 */ 
PROCEDURE  fpt_check_sale_order_all
  (   p_DDP_ID                     IN   VARCHAR2,
      P_SO_number_tbl_all                      IN   SO_number_tbl_all,
      x_return_status                  OUT NOCOPY    VARCHAR2,
      x_msg_count                      OUT NOCOPY    NUMBER,
      x_msg_data                       OUT NOCOPY    VARCHAR2,
      P_SO_number_tbl_out               OUT NOCOPY  SO_number_tbl_out
  );
  

END FPT_CHECK_SONUM_PUB_V1;
/
CREATE OR REPLACE PACKAGE BODY FPT_CHECK_SONUM_PUB_V1  AS
/* $Header: FPT_CHECK_SONUM_PUB_V1.pls 120.3 2005/07/19 18:56:53 repuri ship $ */

  /* Package variables. */

  G_PKG_NAME         CONSTANT VARCHAR2(30) := 'FPT_CHECK_SONUM_PUB_V1';

PROCEDURE fpt_check_sale_order(
															 p_org_id        IN number,
															 P_SO_NUMBER     IN VARCHAR2,
															 x_return_status OUT NOCOPY VARCHAR2,
															 x_msg_count     OUT NOCOPY NUMBER,
															 x_msg_data      OUT NOCOPY VARCHAR2) IS

	cursor c_so_number is
		select 1
			from oe_order_headers_all
		 where org_id = p_org_id
			 and order_number = P_SO_NUMBER;
	r_so_number c_so_number%rowtype;

	cursor c_tran_so is
		select ct.customer_trx_id
			from RA_CUSTOMER_TRX_LINES_all lt, RA_CUSTOMER_TRX_ALL ct
		 where CT.CUSTOMER_TRX_ID = lt.customer_trx_id
			 and ct.org_id = p_org_id
			 and lt.Sales_Order = P_SO_NUMBER
       and rownum = 1;

	

	r_tran_so number;

	cursor c_receipt_num(c_trx_id number, c_org_id number) is
		select ala.receipt_number
				 from AR_RECEIVABLE_APPLICATIONS_ALL aaa,
							AR_PAYMENT_SCHEDULES_ALL       aps,
							AR.RA_CUSTOMER_TRX_ALL         ct,
             AR_CASH_RECEIPTS_ALL     ala
				where aaa.applied_payment_schedule_id = aps.payment_schedule_id
					and ct.trx_number = aps.trx_number
					and ct.org_id = aps.org_id
          and aaa.cash_receipt_id = ala.cash_receipt_id
          and ct.customer_trx_id = c_trx_id
          and ct.org_id =c_org_id;
          


	r_receipt_num c_receipt_num%rowtype;

	v_so_number            oe_order_headers_all.order_number%type := P_SO_NUMBER;
	v_org_id               number := p_org_id;
	v_ddp_id               number;
	v_ddp_request_code     varchar(50);
	v_oe_order_headers_all oe_order_headers_all%rowtype;
	v_count                number;
  p_cust_id              number;
Begin

	x_return_status := 'S';
	---B1: check ton tai
	open c_so_number;
	fetch c_so_number
		into r_so_number;
	if c_so_number%notfound then
		x_return_status := 'S';
		x_msg_count     := 1;
		x_msg_data      := 'SO_Number not exsist';
		return;
	end if;
	close c_so_number;
	-- check da huy

	begin
		select count(*)
			into v_count
			from oe_order_headers_all t
		 where t.org_id = v_org_id
			 and instr(t.orig_sys_document_ref, v_so_number) > 0
			 and t.flow_status_code = 'BOOKED'
			 and t.order_source_id = 2; 
       
       exception when 
         others then v_count := 0;
	end;
	

	if nvl(v_count, 0) > 0 then
		x_return_status := 'S';
		x_msg_count     := 1;
		x_msg_data      := 'sale order is cancel';
		return;
	end if;
	---
	-------B2: check da co invoice cho sale order, get cus_trax_id
  begin
    select count(1)
      into v_count
			from RA_CUSTOMER_TRX_LINES_all lt, RA_CUSTOMER_TRX_ALL ct
		 where CT.CUSTOMER_TRX_ID = lt.customer_trx_id
			 and ct.org_id = p_org_id
			 and lt.Sales_Order = P_SO_NUMBER
       and rownum = 1;
    exception when others then
      v_count := null;
    end;
    if nvl(v_count,0) = 0 then
      x_return_status := 'S';
		x_msg_count     := 1;
		x_msg_data      := 'Invocie of sale order not created';
		return;
      end if;
      
	open c_tran_so;
	/*if c_tran_so%notfound then
		x_return_status := 'S';
		x_msg_count     := 1;
		x_msg_data      := 'Invocie of sale order not created';
		return;
	else*/
		fetch c_tran_so
			into r_tran_so;
	--end if;
  --exit when c_tran_so%notfound;
	close c_tran_so;

	-----B3: get recepit number  
	declare
		v_receipt_number  AR_CASH_RECEIPTS_ALL.Receipt_Number%type;
		v_customer_trx_id number := r_tran_so;
    v_tran_number RA_CUSTOMER_TRX_ALL.Trx_Number%type;
	begin
		   begin
        select  count(1) into v_count
				 from AR_RECEIVABLE_APPLICATIONS_ALL aaa,
							AR_PAYMENT_SCHEDULES_ALL       aps,
							AR.RA_CUSTOMER_TRX_ALL         ct,
             AR_CASH_RECEIPTS_ALL     ala
				where aaa.applied_payment_schedule_id = aps.payment_schedule_id
					and ct.trx_number = aps.trx_number
					and ct.org_id = aps.org_id
          and aaa.cash_receipt_id = ala.cash_receipt_id
          and ct.customer_trx_id = v_customer_trx_id
          and ct.org_id =v_org_id
          and ala.status = 'APP'
          ;
          exception when others then
            v_count := 0;
            end;
     
		if nvl(v_count,0) > 0 then
			-- truong hop co receipt tra lai nhieu receipt number
      for i in ( select ala.receipt_number
				 from AR_RECEIVABLE_APPLICATIONS_ALL aaa,
							AR_PAYMENT_SCHEDULES_ALL       aps,
							AR.RA_CUSTOMER_TRX_ALL         ct,
             AR_CASH_RECEIPTS_ALL     ala
				where aaa.applied_payment_schedule_id = aps.payment_schedule_id
					and ct.trx_number = aps.trx_number
					and ct.org_id = aps.org_id
          and aaa.cash_receipt_id = ala.cash_receipt_id
          and ct.customer_trx_id = v_customer_trx_id
          and ct.org_id =v_org_id
          and ala.status = 'APP') loop
           if x_msg_data is null then
             x_msg_data := i.receipt_number;
             else
           x_msg_data := x_msg_data || ', ' || i.receipt_number;
           end if;
          end loop;
			x_return_status := 'S';
			x_msg_count     := 1;
			x_msg_data      := 'Invoice already cashed. Receipt number is: ' ||
												 x_msg_data;
		-- chua co receipt
    else
      begin
      select t.Trx_Number
      into v_tran_number
      from RA_CUSTOMER_TRX_ALL t
      where t.customer_trx_id = v_customer_trx_id
      and t.org_id = v_org_id;
      exception when others then
        v_tran_number := null;
      end;
      
      x_return_status := 'S';
			x_msg_count     := 1;
			x_msg_data      := 'Invoice ' || v_tran_number || ' not cashed yet';
    end if;
	end;

exception
	when others then
		x_return_status := 'E';
		x_msg_count     := 1;
		x_msg_data      := sqlerrm;
	
end;


PROCEDURE  fpt_check_sale_order_all
  (   p_DDP_ID                     IN   VARCHAR2,
      P_SO_number_tbl_all                      IN   SO_number_tbl_all,
      x_return_status                  OUT NOCOPY    VARCHAR2,
      x_msg_count                      OUT NOCOPY    NUMBER,
      x_msg_data                       OUT NOCOPY    VARCHAR2,
      P_SO_number_tbl_out               OUT NOCOPY  SO_number_tbl_out
  ) is
  
vTab_index NUMBER := P_SO_number_tbl_all.FIRST;
  v_ddp_id number;

  v_ddp_request_code varchar(50);

begin
 
 -- x_ddp_request_code := p_ddp_request_code; -- return gia tri input
	x_return_status := 'S';
  
   --> check ddp_id in process
	begin
		select count(1)
			into v_ddp_id
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'Check_SO'
			 and status = 'P';
	exception
		when others then
			v_ddp_id := null;
	end;   
   if nvl(v_ddp_id,0) >0 then
      x_return_status := 'PE';
      x_msg_count := 1;
      x_msg_data := 'The request with DDP_ID ' || p_ddp_id || ' is in processing!!!';
      return;
      end if;
  --> insert ddp_id
	insert into fpt_ddp_process
		(ddp_id, program, status)
	values
		(p_ddp_id, 'Check_SO', 'P');
    
  WHILE vTab_index <= P_SO_number_tbl_all.LAST LOOP
    
    fpt_check_sale_order(
                         p_org_id => P_SO_number_tbl_all(vTab_index).org_id,
                         P_SO_NUMBER => P_SO_number_tbl_all(vTab_index).Order_number,
                         x_msg_count => x_msg_count,
                         x_return_status => x_return_status,
                         x_msg_data => P_SO_number_tbl_out(vTab_index).x_message);
         P_SO_number_tbl_out(vTab_index).x_ddp_request_code := P_SO_number_tbl_all(vTab_index).ddp_request_code ;         
    
   	vTab_index := vTab_index + 1;
	--	exit when x_return_status = 'E';
   end loop;
   
       
	
  --> update trang thai ddp_id
    update fpt_ddp_process
   set Status = 'S'
   where ddp_id = p_ddp_id
   and program = 'Check_SO' ;
   
   
EXCEPTION 
  WHEN OTHERS THEN
        
        x_return_status := 'E'/*FND_API.G_RET_STS_UNEXP_ERROR*/;
        x_msg_count := 1;
        x_msg_data := sqlerrm;     
end;


END FPT_CHECK_SONUM_PUB_V1 ;
/
