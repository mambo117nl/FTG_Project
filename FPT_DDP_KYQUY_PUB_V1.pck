CREATE OR REPLACE PACKAGE FPT_DDP_KYQUY_PUB_V1  AS
/* $Header: FPT_DDP_KYQUY_PUB_V1.pls 120.3 2022/02/13 18:56:53 repuri ship$ */
/*#
 * Salesperson create and update API
 * This API contains the procedures to export payment Kyquy to DDP.
 * @rep:scope public
 * @rep:product AP
 * @rep:displayname Fpt Payment kyquy API
 * @rep:category BUSINESS_ENTITY FPT_DDP_KYQUY
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf CMM APIs,  Oracle Trading Community Architecture Technical Implementation Guide

*/
  /*****************************************************************************************
   This is a public API that caller will invoke. 
   It provides procedures for export payment Kyquy to DDP.
   Its main procedures are as following:
   Fpt Payment Kyquy API
   ******************************************************************************************/


 TYPE Payment_kyquy_Rec_Type IS RECORD (
  STT number,
  Org_id number,
  Payment_type varchar2(10),
  Payment_date varchar2(20),
  Accounting_date varchar2(20),
  Documment_number  number,
  AP_number  varchar2(20),
  Supplier_number  varchar2(50),
  Payment_currency varchar2(10),
  Payment_rate varchar2(100),
  Account_number varchar2(10),
  Base_Amount    number,
  Amount    number,
  DESCRIPTION    varchar2(200),
  Create_date  varchar2(20),
  Event_ID     number,
  Status      varchar2(20)
  );
  
  
TYPE Payment_kyquy_tbl_Type IS TABLE OF Payment_kyquy_Rec_Type INDEX BY BINARY_INTEGER;



/* Procedure to create API Fpt_Payment_kyquy 
  based on input values passed by calling routines. */
/*#
 * Create Fpt_Payment_kyquy API   
 * This procedure allows the user to export payment kyquy record.
 * @param P_DDP_ID ddp_id
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
 * @param x_Payment_kyquy_tbl_Type ky quy record out.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fpt Payment kyquy API
 */ 
PROCEDURE  Fpt_Payment_kyquy
  (   P_DDP_ID                                   in VARCHAR2,
      x_return_status                  OUT NOCOPY    VARCHAR2,
      x_msg_count                      OUT NOCOPY    NUMBER,
      x_msg_data                       OUT NOCOPY    VARCHAR2,
      x_Payment_kyquy_tbl_Type              OUT NOCOPY    Payment_kyquy_tbl_Type
  );
  

END FPT_DDP_KYQUY_PUB_V1;
/
CREATE OR REPLACE PACKAGE BODY FPT_DDP_KYQUY_PUB_V1  AS
/* $Header: FPT_DDP_KYQUY_PUB_V1.pls 120.3 2022/02/13 18:56:53  repuri ship $ */

  /* Package variables. */

  --G_PKG_NAME         CONSTANT VARCHAR2(30) := 'FPT_DDP_API_PUB_V1';

 
PROCEDURE  Fpt_Payment_kyquy
  (   P_DDP_ID                                   in VARCHAR2,
      x_return_status                  OUT NOCOPY    VARCHAR2,
      x_msg_count                      OUT NOCOPY    NUMBER,
      x_msg_data                       OUT NOCOPY    VARCHAR2,
      x_Payment_kyquy_tbl_Type              OUT NOCOPY    Payment_kyquy_tbl_Type
  ) IS

 v_run  number;
 v_start_run date := sysdate;
 v_last_run date;
 v_first_time_run date := sysdate - 1; --to_date(TO_CHAR(sysdate, 'DD-MON-YYYY') || ' 00:00:00','DD-MON-YYYY HH24:MI:SS')
 n number := 0;
 v_ddp_id varchar2(100) := P_DDP_ID;
 v_count number;
 
Begin
	--> save point to rollback
	--SAVEPOINT Fpt_Payment_kyquy;
  x_return_status := 'S';
     --> check ddp_id in process
  begin
    select count(1)
      into v_count
      from fpt_ddp_process
     where ddp_id = p_ddp_id
       and program = 'get_payment'
       and status = 'P';
  exception
    when others then
      v_count := null;
  end;   
   if nvl(v_count,0) >0  then
      x_return_status := 'PE';
      x_msg_count := 1;
      x_msg_data := 'The request with DDP_ID ' || p_ddp_id || ' is in processing!!!';
      return;
    end if;
      --> check ddp_id da chay roi
  begin
    select count(1) 
    into v_count
    from FPT_DDP_KYQUY_PAYMENT
    where ddp_id = v_ddp_id;
    exception when others then
      v_count := 0;
  end;
    if nvl(v_count,0) > 0 then
      -->Duyet bang trung gian
      for i in (select * from FPT_DDP_KYQUY_PAYMENT where ddp_id = v_ddp_id order by CREATED_DATE asc) loop
        n := n + 1;
          
        x_Payment_kyquy_tbl_Type(n).STT              := n;
        x_Payment_kyquy_tbl_Type(n).Org_id           := i.org_id;
        x_Payment_kyquy_tbl_Type(n).Payment_type     := i.payment_type;
        x_Payment_kyquy_tbl_Type(n).Payment_date     := to_char(i.payment_date,'DD/MM/YYYY');
        x_Payment_kyquy_tbl_Type(n).Accounting_date  := to_char(i.accounting_date,'DD/MM/YYYY');
        x_Payment_kyquy_tbl_Type(n).Documment_number := i.payment_number;
        x_Payment_kyquy_tbl_Type(n).AP_number        := i.invoice_number;
        x_Payment_kyquy_tbl_Type(n).Supplier_number  := i.vendor_number;
        x_Payment_kyquy_tbl_Type(n).Payment_rate     := nvl(i.rate,1);
        x_Payment_kyquy_tbl_Type(n).Payment_currency := i.currency; 
        x_Payment_kyquy_tbl_Type(n).Account_number   := i.accounting_number;        
        x_Payment_kyquy_tbl_Type(n).Base_Amount      := i.base_amount;
        x_Payment_kyquy_tbl_Type(n).Amount           := i.payment_amount;        
        x_Payment_kyquy_tbl_Type(n).DESCRIPTION      := Substr(i.description,1,199);
        x_Payment_kyquy_tbl_Type(n).Create_date      := substr(to_char(i.created_date,'DD/MM/YYYY HH24:MI:SS'),1,20);
        x_Payment_kyquy_tbl_Type(n).Event_ID         := i.accounting_event_id;
        x_Payment_kyquy_tbl_Type(n).Status           := i.accounting_status_final;
   end loop;
   x_msg_count := 1;
   x_msg_data :=  'Success!!!';
        return;    
     end if;
  
  --> insert ddp_id
  insert into fpt_ddp_process
    (ddp_id, program, status, start_time)
  values
    (p_ddp_id, 'get_payment', 'P', sysdate);
  commit;
  
  -- get lan chay truoc
	begin
		select nvl(max(kyquy_run_time),v_first_time_run)
			into v_last_run
			from FPT_DDP_KYQUY_RUN
		;
	exception
		when no_data_found then
			v_last_run := sysdate - 1;
	end;   
  -- insert bang luu lan chay
  select nvl(max(run_id),0) + 1
  into v_run
  from FPT_DDP_KYQUY_RUN;
  
	insert into FPT_DDP_KYQUY_RUN
		(run_id,kyquy_run_time,Status)
	values
		(v_run, v_start_run,'N');      
       
  -- get record ph�t sinh
  Insert into FPT_DDP_KYQUY_PAYMENT      
		(Kyquy_id,
     check_id,
		 Org_id,
		 Payment_type,
		 Payment_date,
		 Accounting_date,
		 Payment_number,
		 Invoice_number,
		 Vendor_number,
		 Currency,
		 Rate,
		 Accounting_Number,
		 Base_Amount,
		 Invoice_amount,
     payment_amount,
		 Description,
		 Created_date,
		 STATUS,
		 RUN_ID,
		 RUM_TIME,
		 accounting_event_id,
     ddp_id,
     accounting_status_final)
      -- insert c�c giao d?ch khi hach toan trong khoang chay tu lan gan nhat
		select FPT_PAYMENT_KYQUY_S.NEXTVAL,
           ac.check_id,
					 ac.org_id,
					 Case when ac.payment_type_flag = 'M' then
             'Manual'
             else 
               'Quick'
               end Payment_type ,
					 ac.check_date,
					 xah.accounting_date,
					 ac.check_number,
					 api.invoice_num,
					 aps.segment1 vendor_number,
					 ac.currency_code,
					 nvl(ac.exchange_rate,1),
					 gcc.segment4,
				/*	case when xal.accounted_dr is null then
             xal.accounted_cr*-1
             else
               xal.accounted_dr
               end*/ round(t.amount*nvl(t.exchange_rate,1),0) Base_Amount,
           case when ac.currency_code = 'VND' then
             api.invoice_amount
             else
              api.Base_Amount
              end invoice_amount,
					 /*case when xal.entered_dr is null then
             xal.entered_cr*-1
             else
               xal.entered_dr
               end*/ t.amount amount,
					 trim(ac.description) description,
					 ac.last_update_date,
					 'N',
					 v_run,
					 v_start_run,
					 t.accounting_event_id,
           v_ddp_id,
            xah.accounting_entry_status_code
			from ap_invoices_all            api,
					 AP.AP_CHECKS_ALL           ac,
					 AP.AP_INVOICE_PAYMENTS_ALL t,
					 gl_code_combinations_kfv   gcc,
           ap.ap_suppliers            aps,
            xla_ae_headers PARTITION (ap) xah  
		 where t.accts_pay_code_combination_id = gcc.code_combination_id
			 and api.invoice_id = t.invoice_id
			 and t.check_id = ac.check_id
       and api.vendor_id = aps.vendor_id
       and substr(gcc.segment4,1,3) = '344'
      and ac.payment_type_flag in ('M','Q')
       and t.accounting_event_id = xah.event_id
       and exists (
                                select 1
                                from  gl_code_combinations_kfv   gcc1,
                                   xla_ae_lines PARTITION (ap) xal1 ,
                                   ( select * from xla_ae_headers PARTITION (ap)
                                   where /*accounting_entry_status_code = 'F' 
                                   and */je_category_name = 'Payments'
                                   and application_id = 200
                                   and completed_date  between v_last_run and v_start_run )      xle
                             where t.accounting_event_id = xle.event_id
                             and t.accts_pay_code_combination_id = xal1.code_combination_id
                             and xal1.code_combination_id = gcc1.code_combination_id
                              and xle.ae_header_id = xal1.ae_header_id
                              and xal1.application_id = 200  
                              and xal1.accounting_class_code = 'LIABILITY'
                               and substr(gcc1.segment4,1,3) = '344'          -- cac in voice ky quy tk 344  
       
        )
   /* and not exists (select 1 from   FPT_DDP_KYQUY_PAYMENT fpk               -- loai cac check_id da insert
                                         where t.accounting_event_id = fpk.accounting_event_id
                                         and fpk.payment_amount <> 0    
                                         and fpk.status = 'Y')*/
	   
    ;
                                          
     commit;
     
     
     begin  
        -- insert c�c giao d?ch t?o d� final c� DFF update trong khoang thoi gian tu lan chay gan nhat
     Insert into FPT_DDP_KYQUY_PAYMENT      
        (Kyquy_id,
         check_id,
         Org_id,
         Payment_type,
         Payment_date,
         Accounting_date,
         Payment_number,
         Invoice_number,
         Vendor_number,
         Currency,
         Rate,
         Accounting_Number,
         Base_Amount,
         Invoice_amount,
         payment_amount,
         Description,
         Created_date,
         STATUS,
         RUN_ID,
         RUM_TIME,
         accounting_event_id,
         ddp_id,
         accounting_status_final)
      
       select FPT_PAYMENT_KYQUY_S.NEXTVAL,
           ac.check_id,
					 t.org_id,
					 Case when ac.payment_type_flag = 'M' then
             'Manual'
             else 
               'Quick'
               end Payment_type
             ,
					 ac.check_date,
					 xle.accounting_date,
					 ac.check_number,
					 api.invoice_num,
					 aps.segment1 vendor_number,
					 ac.currency_code,
					 ac.exchange_rate,
					 gcc.segment4,
					 0  Base_Amount,
           0 invoice_amount,
					 0 amount,
					 trim(ac.description) description,
					 ac.last_update_date,
					 'N',
					 v_run,
					 v_start_run,
					 t.accounting_event_id,
           v_ddp_id,
           xle.accounting_entry_status_code
			from ap_invoices_all            api,
					 AP.AP_CHECKS_ALL           ac,
					 AP.AP_INVOICE_PAYMENTS_ALL t,
					 gl_code_combinations_kfv   gcc,
           ap.ap_suppliers            aps,
           xla_ae_headers  PARTITION (ap)            xle
   
		 where t.accts_pay_code_combination_id = gcc.code_combination_id
			 and api.invoice_id = t.invoice_id
			 and t.check_id = ac.check_id
       and api.vendor_id = aps.vendor_id
       and xle.event_id = t.accounting_event_id
       and ac.payment_type_flag in ('M','Q')         -- lay giao dich quick , manual
      /* and xle.accounting_entry_status_code = 'F'*/   -- trang thai Final
       and xle.application_id = 200  
       and xle.je_category_name = 'Payments'
			 and substr(gcc.segment4,1,3) = '344'          -- cac in voice ky quy tk 344
       and xle.completed_date < v_last_run  -- khi final
       and ac.last_update_date > v_last_run     --- khi sua thong tin DFF o payment lay lai  
       and not exists (select 1 from   FPT_DDP_KYQUY_PAYMENT fpk               -- loai cac check_id da insert
                                         where ac.check_id = fpk.check_id     
                                         and fpk.status = 'N'); 
  
   commit;
   end;
 
  -- xoa cac but toan co TK 11390000, 11390010
  delete FPT_DDP_KYQUY_PAYMENT kt
   where kt.status = 'N'
     and exists (select 1 from AP.AP_INVOICE_PAYMENTS_ALL t1,
                               gl_code_combinations_kfv   gcc1,
                               xla_ae_headers PARTITION (ap)  xle1,
                               xla_ae_lines PARTITION (ap)   xal1 
                         where t1.check_id = kt.check_id
                           and t1.accounting_event_id = xle1.event_id
                           and xle1.ae_header_id = xal1.ae_header_id
                           and xal1.code_combination_id = gcc1.code_combination_id
                           and xal1.application_id = 200
                           and gcc1.segment4 in ('11390000','11390010'));
  -- Tra du lieu to DDP
  for i in (select * from FPT_DDP_KYQUY_PAYMENT where status = 'N' order by CREATED_DATE asc) loop
    n := n + 1;
    
    x_Payment_kyquy_tbl_Type(n).STT := n;
    x_Payment_kyquy_tbl_Type(n).Org_id := i.org_id;
    x_Payment_kyquy_tbl_Type(n).Payment_type := i.payment_type;
    x_Payment_kyquy_tbl_Type(n).Payment_date := to_char(i.payment_date,'DD/MM/YYYY');
    x_Payment_kyquy_tbl_Type(n).Accounting_date := to_char(i.accounting_date,'DD/MM/YYYY');
    x_Payment_kyquy_tbl_Type(n).Documment_number  := i.payment_number;
    x_Payment_kyquy_tbl_Type(n).AP_number  := i.invoice_number;
    x_Payment_kyquy_tbl_Type(n).Supplier_number  := i.vendor_number;
    x_Payment_kyquy_tbl_Type(n).Payment_rate := nvl(i.rate,1);
    x_Payment_kyquy_tbl_Type(n).Payment_currency := i.currency; 
    x_Payment_kyquy_tbl_Type(n).Account_number := i.accounting_number;    
    x_Payment_kyquy_tbl_Type(n).Base_Amount    := i.base_amount;
    x_Payment_kyquy_tbl_Type(n).Amount    := i.payment_amount;    
    x_Payment_kyquy_tbl_Type(n).DESCRIPTION    := Substr(i.description,1,199);
    x_Payment_kyquy_tbl_Type(n).Create_date  := substr(to_char(i.created_date,'DD/MM/YYYY HH24:MI:SS'),1,20);
    x_Payment_kyquy_tbl_Type(n).Event_ID := i.accounting_event_id;
    -- them truong status
    x_Payment_kyquy_tbl_Type(n).Status  := i.accounting_status_final;
    -- cap nhat trang thai tra ve
    
    update FPT_DDP_KYQUY_PAYMENT
       set status = 'Y'
    where KYQUY_ID = i.kyquy_id;
  
  end loop;
    
  if x_return_status = fnd_api.g_ret_sts_success then
    -- update trang tai run
    update FPT_DDP_KYQUY_RUN
       set status = 'Y', end_time = sysdate
     where run_id = v_run;
     
    delete FPT_DDP_KYQUY_PAYMENT where status = 'N';
     
    x_msg_count := 1;
    x_msg_data := 'Success!!!';
    commit;
  end if;
 
 --> update trang thai ddp_id
   update fpt_ddp_process
      set Status = 'S',
          end_time = sysdate
    where ddp_id = p_ddp_id
      and program = 'get_payment'
      and status = 'P';   
    commit;
EXCEPTION WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       /* FND_MESSAGE.SET_NAME('AP', 'FPT_DDP_API_PUB_V1');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);   */   
        x_msg_count := 1;
        x_msg_data := SQLERRM;
        rollback;                          
end;
END FPT_DDP_KYQUY_PUB_V1 ;
/
