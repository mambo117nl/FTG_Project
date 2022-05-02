CREATE OR REPLACE PACKAGE FPT_DDP_CAT_KQ_PUB_V1  AS
/* $Header: FPT_DDP_CAT_KQ_PUB_V1.pls 120.3 2005/07/19 18:56:53 repuri ship$ */
/*#
 * Salesperson create and update API
 * This API contains the procedures to insert and update Kyquy record.
 * @rep:scope public
 * @rep:product AP
 * @rep:displayname Create DDP Cat KYQUY API
 * @rep:category BUSINESS_ENTITY INV_REC_CAT_KYQUY_IMPORT

*/
  /*****************************************************************************************
   This is a public API that caller will invoke. 
   It provides procedures for managing Salesreps, like
   create and update Salesreps from other modules.
   Its main procedures are as following:
   create_ddp_cat_kyquy_all
   ******************************************************************************************/


 TYPE DDP_Cat_Kyquy_Rec_Type IS RECORD (

      DDP_REQUEST_CODE  VARCHAR2(50),
      ORG_ID  NUMBER,
      --- invocie
      BATCH_ID     number,
      INVOICE_DATE  VARCHAR2(100),
      VENDOR_ID     number,
      VENDOR_SITE_ID  number,
      INV_AMOUNT  NUMBER,
      DESCRIPTION  ap_invoices_all.description%type,
      INV_CURRENCY  VARCHAR2(100),
      INV_RATE  NUMBER,
      INV_TERM  VARCHAR2(100),
      INV_PAYMENT_METHOD  VARCHAR2(100),
      INV_HOADON  VARCHAR2(100),
      LINE_NUMBER  NUMBER,
      DEFAULT_ACCOUNT    VARCHAR2(100),
      LINE_DESCRIPTION  ap_invoice_lines.description%type, 
      ---- Payment Zero      
      PAY_DESCRIPTION        ap_checks_all.description%type,      
      PAY_BANK_ACCOUNT_NAME  VARCHAR2(100),
      PAY_SOPHIEU            VARCHAR2(240),       
      PAY_KYQUY_INVOICE_ID   number            
  );
  
  
TYPE DDP_Cat_Kyquy_Tbl_Type IS TABLE OF DDP_Cat_Kyquy_Rec_Type INDEX BY BINARY_INTEGER;


TYPE DDP_Cat_Kyquy_Rec_Type_out IS RECORD
  (
   ddp_request_code         VARCHAR2(50),
   x_Invoice_batch_ID        number,
   x_Invoice_number         ap_invoices_all.invoice_num%type,
   X_Invoice_id              Number,
   --- rev
   x_check_number      ap_checks_all.check_number%type,
   X_check_id             Number
   );
   
TYPE DDP_Cat_Kyquy_Tbl_Type_out IS TABLE OF DDP_Cat_Kyquy_Rec_Type_out INDEX BY BINARY_INTEGER;

TYPE DDP_Cat_Kyquy_Input_Rec IS RECORD(
  term_id             number,
  lib_acct_id         number,
  def_acct_id         number,
  sob_id              number,
  payment_profile_id  number,
  payment_document_id number,
  legal_entity_id     number,
  bank_account_id     ce.ce_bank_accounts.bank_account_id%type, 
  bank_account_num    ce.ce_bank_accounts.bank_account_num%type,
  bank_account_name   ce.ce_bank_accounts.bank_account_name%type,
  bank_acct_use_id    ce.ce_bank_acct_uses_all.bank_acct_use_id%type,
  vendor_name         ap_suppliers.vendor_name%type, 
  vendor_site_code    ap_supplier_sites_all.vendor_site_code%type,
  address_line1       ap_supplier_sites_all.address_line1%type,
  party_id            number,
  party_site_id       number,
  Invoice_batch_ID    number,
  invoice_id          number,
  check_id            number,
  ddp_request_code    varchar2(50),
  ORG_ID              number,
  BATCH_NAME          ap_batches_all.batch_name%type
);

TYPE DDP_Cat_Kyquy_Input_Tbl is table of DDP_Cat_Kyquy_Input_Rec index by binary_integer;


/* Procedure to import Credit Kyquy to invoice and receipt 
  based on input values passed by calling routines. */
/*#
 * Create Cat Kyquy invocie and receipt API   
 * This procedure allows the user to create a kyquy record.
 * @param p_DDP_ID batch ID.


 * @param P_DDP_Cat_Kyquy_Tbl Kyquy record.
 
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
 * @param x_ddp_request_code   ddp_request_code loi
* @param x_DDP_Cat_Kyquy_Tbl_out record out put
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create DDP Cat KYQUY API
 */ 
PROCEDURE  create_ddp_cat_kyquy_all
  (   p_DDP_ID                     IN   VARCHAR2,
      P_DDP_Cat_Kyquy_Tbl                  IN  DDP_Cat_Kyquy_Tbl_Type,    
      x_return_status                  OUT NOCOPY    VARCHAR2,
      x_msg_count                      OUT NOCOPY    NUMBER,
      x_msg_data                       OUT NOCOPY    VARCHAR2,
      x_ddp_request_code         OUT NOCOPY VARCHAR2,
      x_DDP_Cat_Kyquy_Tbl_out          OUT NOCOPY DDP_Cat_Kyquy_Tbl_Type_out
  );
  

END FPT_DDP_CAT_KQ_PUB_V1;
/
CREATE OR REPLACE PACKAGE BODY FPT_DDP_CAT_KQ_PUB_V1  AS
/* $Header: FPT_DDP_CAT_KQ_PUB_V1.pls 120.3 2005/07/19 18:56:53 repuri ship $ */

  

  /* Package variables. */

--G_PKG_NAME         CONSTANT VARCHAR2(30) := 'FPT_DDP_CAT_KQ_PUB_V1';
g_group_id varchar2(100);
gInput DDP_Cat_Kyquy_Input_Tbl;

FUNCTION split_segment(P_SEGMENTS VARCHAR2, P_SEGMENT_NUM NUMBER) RETURN VARCHAR2 IS
    V_FROM_INDEX INTEGER;
    V_TO_INDEX   INTEGER;
  BEGIN
  
    IF P_SEGMENT_NUM = 1 THEN
      V_FROM_INDEX := 0;
    ELSE
      V_FROM_INDEX := INSTR(P_SEGMENTS, '.', 1, P_SEGMENT_NUM - 1);
    END IF;
  
    V_TO_INDEX := INSTR(P_SEGMENTS, '.', 1, P_SEGMENT_NUM);
  
    IF V_TO_INDEX = 0 THEN
      V_TO_INDEX := LENGTH(P_SEGMENTS) + 1;
    END IF;
  
    RETURN SUBSTR(P_SEGMENTS, V_FROM_INDEX + 1, V_TO_INDEX - V_FROM_INDEX - 1);
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  
FUNCTION get_coa_id(P_LEDGER_ID NUMBER) RETURN NUMBER IS
    V_COA_ID NUMBER;
  BEGIN
    SELECT L.CHART_OF_ACCOUNTS_ID
      INTO V_COA_ID
      FROM GL.GL_LEDGERS L
     WHERE L.LEDGER_ID = P_LEDGER_ID;
    RETURN V_COA_ID;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN - 1;
  END;  
  
FUNCTION get_ccid(P_LEDGER_ID     NUMBER,
                    P_SEGMENT1      VARCHAR2,
                    P_SEGMENT2      VARCHAR2,
                    P_SEGMENT3      VARCHAR2,
                    P_SEGMENT4      VARCHAR2,
                    P_SEGMENT5      VARCHAR2,
                    P_SEGMENT6      VARCHAR2,
                    P_SEGMENT7      VARCHAR2,
                    P_SEGMENT8      VARCHAR2,
                    P_ERROR_MESSAGE OUT VARCHAR2) RETURN NUMBER IS
  
    V_COMBINATION_ID NUMBER;
    V_RETURN         BOOLEAN;
    V_SEGMENTS       APPS.FND_FLEX_EXT.SEGMENTARRAY;
    V_COA_ID         NUMBER;
    /*V_USER_ID        NUMBER := NVL(FND_PROFILE.VALUE('USER_ID'), 0);
    V_RESP_ID        NUMBER := NVL(FND_PROFILE.VALUE('RESP_ID'), 20434);
    V_RESP_APPL_ID   NUMBER := NVL(FND_PROFILE.VALUE('RESP_APPL_ID'), 101);*/
  BEGIN
    V_COA_ID := GET_COA_ID(P_LEDGER_ID);
    IF V_COA_ID <= 0 THEN
      P_ERROR_MESSAGE := 'DOES NOT EXIST CHART OF ACCOUNT FOR LEDGER ' || P_LEDGER_ID;
      RETURN - 1;
    END IF;
  
    V_SEGMENTS(1) := P_SEGMENT1;
    V_SEGMENTS(2) := P_SEGMENT2;
    V_SEGMENTS(3) := P_SEGMENT3;
    V_SEGMENTS(4) := P_SEGMENT4;
    V_SEGMENTS(5) := P_SEGMENT5;
    V_SEGMENTS(6) := P_SEGMENT6;
    V_SEGMENTS(7) := P_SEGMENT7;
    V_SEGMENTS(8) := P_SEGMENT8;
  
    FND_GLOBAL.APPS_INITIALIZE(0, 20434, 101);
  
    V_RETURN := FND_FLEX_EXT.GET_COMBINATION_ID(APPLICATION_SHORT_NAME => 'SQLGL',
                                                KEY_FLEX_CODE          => 'GL#',
                                                STRUCTURE_NUMBER       => V_COA_ID,
                                                VALIDATION_DATE        => SYSDATE,
                                                N_SEGMENTS             => 8,
                                                SEGMENTS               => V_SEGMENTS,
                                                COMBINATION_ID         => V_COMBINATION_ID,
                                                DATA_SET               => NULL);
  
    -- RESET TO PREVIOUS PROFILE
    --FND_GLOBAL.APPS_INITIALIZE(V_USER_ID, V_RESP_ID, V_RESP_APPL_ID);
  
    IF V_RETURN THEN
      RETURN V_COMBINATION_ID;
    END IF;
  
    P_ERROR_MESSAGE := FND_FLEX_EXT.GET_MESSAGE;
    RETURN - 1;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_ERROR_MESSAGE := 'GET_COMBINATION_ID\' || SUBSTR(SQLERRM, 1, 230);
      RETURN - 1;
  END;

  
FUNCTION get_ccid_seg1(P_ALL_SEGMENTS VARCHAR2, p_org_id number, P_ERROR_MESSAGE OUT VARCHAR2)
    RETURN NUMBER IS
    vLedger_Id number;
    vSegment1  varchar2(15);
    vcount number;
  BEGIN
    vSegment1 := SPLIT_SEGMENT(P_ALL_SEGMENTS, 1);
    select t.SET_OF_BOOKS_ID
      into vLedger_Id
      from fpt_org_company_v t
     where t.SEGMENT1 = vSegment1
       and rownum = 1;    
    if   p_org_id is not null then
      begin
        select count(*)
          into vcount
          from FPT_COMPANY_CODE_ORG t
         where t.org_id = p_org_id
           and t.SEGMENT1 = vSegment1;
      exception
        when others then
          vcount := 0;
      end;        
      
      if nvl(vcount,0) = 0 then
        P_ERROR_MESSAGE := 'segment1 is not right for the org_id!';
        RETURN - 2;
        end if;
     end if;
    RETURN GET_CCID(P_LEDGER_ID     => vLedger_Id,
                    P_SEGMENT1      => SPLIT_SEGMENT(P_ALL_SEGMENTS, 1),
                    P_SEGMENT2      => SPLIT_SEGMENT(P_ALL_SEGMENTS, 2),
                    P_SEGMENT3      => SPLIT_SEGMENT(P_ALL_SEGMENTS, 3),
                    P_SEGMENT4      => SPLIT_SEGMENT(P_ALL_SEGMENTS, 4),
                    P_SEGMENT5      => SPLIT_SEGMENT(P_ALL_SEGMENTS, 5),
                    P_SEGMENT6      => SPLIT_SEGMENT(P_ALL_SEGMENTS, 6),
                    P_SEGMENT7      => SPLIT_SEGMENT(P_ALL_SEGMENTS, 7),
                    P_SEGMENT8      => SPLIT_SEGMENT(P_ALL_SEGMENTS, 8),
                    P_ERROR_MESSAGE => P_ERROR_MESSAGE);
  
 
  EXCEPTION
    WHEN OTHERS THEN
     -- P_ERROR_MESSAGE := 'GET_COMBINATION_ID\' || SUBSTR(SQLERRM, 1, 230);
     P_ERROR_MESSAGE := 'Account not exsits';
      RETURN - 1;
  END;
FUNCTION get_term_id(P_TERM_NAME VARCHAR2) RETURN NUMBER IS
    V_TERMID NUMBER;
	BEGIN
		SELECT TERM_ID
			INTO V_TERMID
			FROM AP_TERMS
		 WHERE NAME = P_TERM_NAME
			 AND ROWNUM = 1;
	
		IF NVL(V_TERMID, 0) = 0 THEN
			RETURN - 1;
		END IF;
    RETURN V_TERMID;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN - 1;
	END;  
 function get_invoice_id(p_invoice_num varchar2) return number is
    v_invoice_id number;
	begin
		select invoice_id
			into v_invoice_id
			from ap_invoices_all
		 where invoice_num = p_invoice_num
			 and rownum = 1;
	
		if nvl(v_invoice_id, 0) = 0 then
			return - 1;
		end if;
    return v_invoice_id;
	exception
		when others then
			return - 1;
	end;  

function get_vendor(p_invoice_id number) return number is
    v_vendor_id number;
	begin
		select vendor_id
			into v_vendor_id
			from ap_invoices_all
		 where invoice_id = p_invoice_id
			 and rownum = 1;
       
    return(v_vendor_id);
	exception
		when others then
			return - 1;
	end;  
  
FUNCTION check_period(p_org_id number, p_gl_date date) return number is
	v_status number;
  
begin
	select count(*)
		into v_status
		from gl_period_statuses   ps,
				 gl_sets_of_books     sob,
				 fpt_company_code_org fcc
	 where ps.set_of_books_id = sob.set_of_books_id
		 and fcc.set_of_books_id = ps.set_of_books_id
		 and p_gl_date between ps.start_date and ps.end_date
		 and fcc.org_id = p_org_id
		 and ps.application_id = 200
		 and ps.closing_status = 'O';

	if nvl(v_status, 0) = 0 then
		return - 1;
	end if;
	return v_status;
exception
	when others then
		return - 1;
end;

Function check_batch(p_batch_id number, p_batch_name out varchar2) return boolean is
  begin
    if p_batch_id is null then
      return true;
    end if;
    
    select batch_name into p_batch_name
      from ap_batches_all x
     where x.batch_id = p_batch_id;
    return true;
  exception
    when others then
      return false;
  end; 

    
procedure validate_invoice_submit(p_invoice_id number default null, p_request_id out number)is
  
    v_req_id     number;
    v_result     boolean;
    v_phase_out  varchar2(240);
    v_status     varchar2(240);
    v_dev_phase  varchar2(240);
    v_dev_status varchar2(240);
    v_message    varchar2(240);
    v_invoice_id number := p_invoice_id;
  begin
  
    fnd_global.apps_initialize(user_id    => 0,
                             resp_id      => 20639, -- 'AP Admin'
                             resp_appl_id => 200
                            );
                            
    v_req_id := fnd_request.submit_request(application => 'SQLAP',
                                           program     => 'APPRVL',
                                           description => 'invoice validation',
                                           start_time  => null,
                                           sub_request => null,
                                           argument1   => '' -- org_id
                                          ,argument2   => 'All' -- matching options for payables autoapproval
                                          ,argument3   => '' -- invoice batch id
                                          ,argument4   => ''-- start invoice date
                                          ,argument5   => '' -- end invoice date
                                          ,argument6   => '' -- vendor id
                                          , argument7   => '' -- pay group
                                          ,argument8   => v_invoice_id -- invoice id
                                          ,argument9   => '' -- entered by user id
                                          ,argument10  => 'N' -- -- trace option
                                          ,argument11  => '' -- commit size
                                          ,argument12  => null
                                           ,argument13  => null --num of transactions
                                          ,argument14  => null
                                          , argument15  => null);
  
    commit;
    p_request_id := v_req_id;
    if v_req_id = 0 then      
      return;
    end if;
    v_result := fnd_concurrent.wait_for_request(v_req_id -- request id
                                               ,10 -- interval
                                               ,0 --99            -- max wait
                                               ,v_phase_out -- phase
                                               ,v_status -- status
                                               ,v_dev_phase -- dev_phase
                                               ,v_dev_status -- dev_status
                                               ,v_message -- v_message
                                                );
  
    commit;
  
  exception
    when others then
      p_request_id := -1;
      fnd_file.put_line(fnd_file.log,
                        'error in submit validate invoice: ' || sqlerrm);
 
 end;
  
FUNCTION submit_payables_import  (pin_org_id     IN NUMBER,
                                   piv_source     IN VARCHAR2,
                                   piv_group_id   IN VARCHAR2,
                                   piv_batch      IN VARCHAR2
                                   
                                  ) RETURN NUMBER IS

    lv_request_id  NUMBER;
    lv_result      BOOLEAN;
    lv_phase1      VARCHAR2(100);
    lv_status1     VARCHAR2(100);
    lv_dev_phase1  VARCHAR2(100);
    lv_dev_status1 VARCHAR2(100);
    lv_message1    VARCHAR2(100);
  
  BEGIN
   
    fnd_global.apps_initialize(user_id    => 0,
                             resp_id      => 20639, -- 'AP Admin'
                             resp_appl_id => 200
                            );
    -- Submit Payables Invoice Import program:
    lv_request_id := fnd_request.submit_request
                            (application => 'SQLAP',
                             program     => 'APXIIMPT',
                             description => NULL,
                             start_time  => NULL,
                             sub_request => NULL,
                             argument1   => pin_org_id,    --Operating Unit
                             argument2   => piv_source,    --Source
                             argument3   => piv_group_id,  --Group
                             argument4   => piv_batch,  --Invoice Batch Name
                             argument5   => NULL,          --Hold Name
                             argument6   => NULL,          --Hold Reason
                             argument7   => NULL,          --GL Date
                             argument8   => 'N',           --Purge
                             argument9   => 'N',           --Trace Switch
                             argument10  => 'N',           --Debug Switch
                             argument11  => 'N',           --Summarize Report
                             argument12  => 1000,          --Commit Batch Size
                             argument13  => fnd_profile.VALUE('USER_ID'), --User ID
                             argument14  => fnd_profile.VALUE('LOGIN_ID') --Login ID
                            );
    COMMIT;
   
    IF lv_request_id = 0 THEN
      dbms_output.put_line(' Failed to submit request Process.');
    ELSE
      lv_result := fnd_concurrent.wait_for_request(lv_request_id,
                                                   10,
                                                   0,
                                                   lv_phase1,
                                                   lv_status1,
                                                   lv_dev_phase1,
                                                   lv_dev_status1,
                                                   lv_message1);
    END IF;
   
    IF NOT lv_result THEN
      dbms_output.put_line('No Status for the request Id: ' ||lv_request_id);
    ELSE
      dbms_output.put_line('The Req-Id of request Process is ' || lv_request_id);
    END IF;

   
    
    return lv_request_id;
  EXCEPTION
    WHEN OTHERS THEN  
      return -1;
      dbms_output.put_line('Others exception. Error' ||SQLERRM);
  END ;
   
PROCEDURE import_credit_invocie(p_ddp_cat_kyquy_rec_all in ddp_cat_kyquy_rec_type,
                          p_Input                       in DDP_Cat_Kyquy_Input_Rec,
													x_return_status               out nocopy varchar2,
													x_msg_count                   out nocopy number,
													x_msg_data                    out nocopy varchar2,
													x_ddp_request_code            out nocopy varchar2,
                          x_request_id                  out nocopy number,
                          x_Invoice_batch_ID            out nocopy number,
                          x_Invoice_number              out nocopy ap_invoices_all.invoice_num%type,
                          X_Invoice_id                  out nocopy number) is

	v_ddp_kyquy_rec_all ddp_cat_kyquy_rec_type := p_ddp_cat_kyquy_rec_all;
	--v_erros_message     varchar2(200);
	--verr                varchar2(200);
  v_invoice_id        ap_invoices_all.invoice_id%TYPE ;
  v_batch_id          ap_invoices_all.batch_id%TYPE ;
  v_invoice_num       ap_invoices_all.invoice_num%type;
  v_invoice_line_id   ap_invoice_lines_interface.invoice_line_id%type;
	v_group_id          ap_invoices_interface.group_id%type ;
	v_vendor_id         po_vendor_sites_all.vendor_id%type;
	v_vendor_site_id    po_vendor_sites_all.vendor_site_id%type;
	v_termid            ap_terms.term_id%type;
	v_org_id            number;
	v_user_id           number := fnd_profile.value('user_id');
	inv_ccid            number;
	default_ccid        number;
  v_source            varchar2(100) := 'MANUAL INVOICE ENTRY';
  v_request_id        number;
  v_val_id            number;
begin
  x_return_status := 'S';
	--v_erros_message := null;  
  select ap_invoices_interface_s.nextval into v_invoice_id from dual;
  select ap_invoice_lines_interface_s.nextval into v_invoice_line_id from dual;
  v_invoice_num := 'KQ-'||to_char(v_invoice_id);
  v_org_id := v_ddp_kyquy_rec_all.ORG_ID;
  -- get group_id 
  v_group_id := p_Input.BATCH_NAME || '.' || v_invoice_id;
	--> get term_id
  v_termid := get_term_id(v_ddp_kyquy_rec_all.inv_term);
 -- v_vendor_id := v_ddp_kyquy_rec_all.VENDOR_ID;
  v_vendor_site_id := v_ddp_kyquy_rec_all.VENDOR_SITE_ID;
	-- get vendor_id,vendor_site_id  
  v_vendor_id := v_ddp_kyquy_rec_all.vendor_id;        
	
  inv_ccid     := p_Input.lib_acct_id;	
  default_ccid := p_Input.def_acct_id;
   
   
   -->Insert interface header  
	 begin
		insert into ap_invoices_interface
			(invoice_id,
       invoice_num,
			 invoice_type_lookup_code,
			 invoice_date,
			 vendor_id,
			 vendor_site_id,
			 invoice_amount,
			 invoice_currency_code,
			 exchange_rate,
			 exchange_rate_type,
			 exchange_date,
			 terms_id,
			 terms_name,
			 description,
			 last_update_date,
			 last_updated_by,
			 creation_date,
			 created_by,
			 attribute_category,
			 attribute1, 
			 attribute11,
			 payment_method_code,        
			 source,
			 doc_category_code,
			 gl_date,
			 accts_pay_code_combination_id,
			 org_id,
			 group_id)
		
		values
		
			(v_invoice_id,
       v_invoice_num,
			 'DEBIT',
			 to_date(v_ddp_kyquy_rec_all.invoice_date,'DD/MM/YYYY'),
			 v_vendor_id,
			 v_vendor_site_id,
			 v_ddp_kyquy_rec_all.inv_amount,
			 v_ddp_kyquy_rec_all.inv_currency,
			 v_ddp_kyquy_rec_all.inv_rate,
			 'User', 
			 to_date(v_ddp_kyquy_rec_all.invoice_date,'DD/MM/YYYY'),
			 v_termid,
			 v_ddp_kyquy_rec_all.inv_term,
			 v_ddp_kyquy_rec_all.description,
			 sysdate,
			 v_user_id,
			 sysdate,
			 v_user_id,
			 'Other Invoice', 
			 v_ddp_kyquy_rec_all.ddp_request_code, -- danh dau invoice 
			 v_ddp_kyquy_rec_all.inv_hoadon, --att11
			 nvl(v_ddp_kyquy_rec_all.inv_payment_method,'CHECK'),
			 v_source,
			 null, 
			 to_date(v_ddp_kyquy_rec_all.invoice_date,'DD/MM/YYYY'),
			 inv_ccid, 
			 v_org_id,
			 v_group_id);
    
    -->Insert interface line
		insert into ap_invoice_lines_interface
			(invoice_id,
			 invoice_line_id,
			 line_number,
			 line_type_lookup_code,
			 amount,
			 accounting_date,
			 description,
			 dist_code_combination_id,
			 last_update_date,
			 last_updated_by,
			 creation_date,
			 created_by,
			 org_id)
		values
			(v_invoice_id,
			 v_invoice_line_id,
			 1,
			 'ITEM',
			 v_ddp_kyquy_rec_all.inv_amount,
			 to_date(v_ddp_kyquy_rec_all.invoice_date,'DD/MM/YYYY'),
			 v_ddp_kyquy_rec_all.line_description,
			 default_ccid,
			 sysdate,
			 v_user_id,
			 sysdate,
			 v_user_id,
			 v_org_id);		
    
    exception when others then
      x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := 'loi iinsert data';
			x_ddp_request_code := v_ddp_kyquy_rec_all.ddp_request_code;
			return;
    end;
	  
    commit;    
	  -- sumit request import 
    v_request_id := submit_payables_import(pin_org_id     => v_org_id,
                                           piv_source     => v_source,
                                           piv_group_id   => v_group_id, -- batch_name.Invoice_id
                                           piv_batch      => p_Input.BATCH_NAME);  
    
		if v_request_id > 0 then
     
			select invoice_id, batch_id
				into v_invoice_id, v_batch_id
				from ap_invoices_all
			 where invoice_num = v_invoice_num; 
       
       -->Update invoice num
       update ap_invoices_all
          set invoice_num = v_invoice_id
        where invoice_id = v_invoice_id;
        commit;
       --------- update batch
        update ap_batches_all t
       set t.org_id = v_org_id
       where t.batch_id  =  v_batch_id;
       commit;
      --validate invoice
      validate_invoice_submit(p_invoice_id => v_invoice_id, p_request_id => v_val_id);  
      
      if v_val_id > 0 then         
        -->Output   
        x_return_status    := 'S';
        x_msg_count        := 1;
        x_msg_data         := 'Request Import Success';
        x_ddp_request_code := v_ddp_kyquy_rec_all.DDP_REQUEST_CODE;
        x_request_id       := v_request_id;
        x_Invoice_batch_ID := v_batch_id;
        x_Invoice_number   := v_invoice_id;
        X_Invoice_id       := v_invoice_id;
      else 
        x_return_status    := 'E';
        x_msg_count        := 1;
        x_msg_data         := 'Fail to request validation invocie';
        x_ddp_request_code := v_ddp_kyquy_rec_all.DDP_REQUEST_CODE; 
      end if;
    else
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'Fail to request import invocie';
      x_ddp_request_code := v_ddp_kyquy_rec_all.DDP_REQUEST_CODE; 
    end if;
    
exception
	when others then
		x_return_status    := 'E';
		x_msg_count        := 1;
		x_msg_data         := sqlerrm;
		x_ddp_request_code := v_ddp_kyquy_rec_all.ddp_request_code;
    rollback;
    return;
end;


PROCEDURE  create_ddp_cat_kyquy_all
  (   p_ddp_id                     in   varchar2,
      p_ddp_cat_kyquy_tbl                  in  ddp_cat_kyquy_tbl_type,    
      x_return_status                  out nocopy    varchar2,
      x_msg_count                      out nocopy    number,
      x_msg_data                       out nocopy    varchar2,
      x_ddp_request_code         out nocopy varchar2,
      x_DDP_Cat_Kyquy_Tbl_out          OUT NOCOPY ddp_cat_kyquy_tbl_type_out
  ) is

	v_index             number := p_ddp_cat_kyquy_tbl.first;
  v_DDP_Cat_Kyquy_Tbl ddp_cat_kyquy_tbl_type := p_ddp_cat_kyquy_tbl;
  v_request_id        number;
  default_ccid        number;
  v_count             number;
  verr                varchar2(200);
  v_start_date        date ;
  v_retcode           varchar2(100);
  v_error_buf         varchar2(100);
  vCheck_id           number;
  vInvoice_batch_ID   number;
  vInvoice_number     varchar2(100);
  vInvoice_id         number;
begin
  -->save point 
	-->SAVEPOINT create_ddp_kyquy_all;
  v_start_date := sysdate;
	x_return_status := fnd_api.g_ret_sts_success;  
  g_group_id := p_DDP_ID;
  --> check ddp_id in process
	begin
		select count(1)
			into v_count
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'Cat_Kyquy'
			 and status = 'P';
	exception
		when others then
			v_count := null;
	end;   
   if nvl(v_count,0) >0 then
      x_return_status := 'PE';
      x_msg_count := 1;
      x_msg_data := 'The request with DDP_ID ' || p_ddp_id || ' is in processing!!!';
      return;
    end if;
      --> check ddp_id da chay roi
	begin
		select count(1)
			into v_count
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'Cat_Kyquy'
			 and status = 'S';
	exception
		when others then
			v_count := null;
	end;   
    if nvl(v_count,0) >0 then
    -- tra du lieu khi goi lai ddp_id da chay thanh cong 
      for i in 1 .. p_ddp_cat_kyquy_tbl.COUNT LOOP 
				begin
					select 
                  x_Invoice_batch_ID,
                  x_Invoice_number,
                  X_Invoice_id,
                  x.x_check_id,
                  x.x_check_number,
                  ddp_request_code
                 
						into x_DDP_Cat_Kyquy_Tbl_out(i).x_Invoice_batch_ID,
                  x_DDP_Cat_Kyquy_Tbl_out(i).x_Invoice_number,
                  x_DDP_Cat_Kyquy_Tbl_out(i).X_Invoice_id,                  
                  x_DDP_Cat_Kyquy_Tbl_out(i).x_check_id,
                  x_DDP_Cat_Kyquy_Tbl_out(i).x_check_number,
                  x_DDP_Cat_Kyquy_Tbl_out(i).ddp_request_code
						from FPT_DDP_CAT_KYQUY x
					 where ddp_id = p_ddp_id
						 and stt = i;
				exception
					when others then
					null;
				end; 
      end loop;
     
      x_return_status := 'S';
      x_msg_count := 1;
      x_msg_data := 'Success!';
      return;
    end if;
      
    --> insert ddp_id
    insert into fpt_ddp_process
      (ddp_id, program, status, start_time)
    values
      (p_ddp_id, 'Cat_Kyquy', 'P', sysdate);
    
   -- check data input
  	WHILE v_index <= p_ddp_cat_kyquy_tbl.LAST LOOP
      if v_DDP_Cat_Kyquy_Tbl(v_index).inv_amount > 0 then
        x_return_status    := 'E';
        x_msg_count        := 1;
        x_msg_data         := 'Invoice amount is invalid! It must negative number';
        x_ddp_request_code := v_DDP_Cat_Kyquy_Tbl(v_index).ddp_request_code;
      end if;
      --> check batch
      if not check_batch(p_batch_id   => v_DDP_Cat_Kyquy_Tbl(v_index).batch_id,
                         p_batch_name => gInput(v_index).batch_name) then
        x_return_status    := 'E';
        x_msg_count        := 1;
        x_msg_data         := 'Batch_ID does not exists.';
        x_ddp_request_code := v_DDP_Cat_Kyquy_Tbl(v_index).ddp_request_code;
        goto STOP; 
      end if;
      --->gInput(v_index).batch_name := 'ThuyTT13-catkyquy';
      --> check term_id
      gInput(v_index).term_id := get_term_id(v_DDP_Cat_Kyquy_Tbl(v_index).inv_term);
      if gInput(v_index).term_id = -1 then
        x_return_status    := 'E';
        x_msg_count        := 1;
        x_msg_data         := 'Inv_term does not exists.';
        x_ddp_request_code := v_DDP_Cat_Kyquy_Tbl(v_index).ddp_request_code;
        goto STOP;   
     end if;     
     -- check mo ky GL
     if check_period(v_DDP_Cat_Kyquy_Tbl(v_index).org_id,to_date(v_DDP_Cat_Kyquy_Tbl(v_index).invoice_date,'DD/MM/YYYY')) = -1 then
       x_return_status    := 'E';
        x_msg_count        := 1;
        x_msg_data         := 'GL period dose not open';
        x_ddp_request_code := v_DDP_Cat_Kyquy_Tbl(v_index).ddp_request_code;
        goto STOP;
     end if;
       
    -- check vendor_id,vendor_site_code
    begin
      select a.ACCTS_PAY_CODE_COMBINATION_ID
        into gInput(v_index).lib_acct_id
        from po_vendor_sites_all a, po_vendors b
       where b.VENDOR_id = v_DDP_Cat_Kyquy_Tbl(v_index).VENDOR_id
         and a.VENDOR_id = v_DDP_Cat_Kyquy_Tbl(v_index).VENDOR_id
         and a.vendor_site_id = v_DDP_Cat_Kyquy_Tbl(v_index).vendor_site_id
         and a.ORG_ID = v_DDP_Cat_Kyquy_Tbl(v_index).org_id
         and rownum = 1;
    exception
      when others then
        x_return_status    := 'E';
        x_msg_count        := 1;
        x_msg_data         := 'Vendor_number or Vendor site id or org_id does not exsits';
        x_ddp_request_code := v_DDP_Cat_Kyquy_Tbl(v_index).ddp_request_code;                      
        goto STOP;
    end;
  	  
    -- check payment method code
    select count(*)
      into v_count
      from iby_payment_methods_vl x
     where payment_method_code = v_DDP_Cat_Kyquy_Tbl(v_index).inv_payment_method
       and (x.INACTIVE_DATE is null or x.INACTIVE_DATE > sysdate);
    if nvl(v_count, 0) = 0 then
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := x_msg_data || 'Payment_method_code is invalid.';
      x_ddp_request_code := v_DDP_Cat_Kyquy_Tbl(v_index).ddp_request_code;
      goto STOP;
    end if;
        
    -- check default_account
    if v_DDP_Cat_Kyquy_Tbl(v_index).default_account is not null then
      default_ccid := get_ccid_seg1(p_all_segments  => v_DDP_Cat_Kyquy_Tbl(v_index).default_account,
                                    p_org_id        => v_DDP_Cat_Kyquy_Tbl(v_index).org_id,
                                    p_error_message => verr);
      if default_ccid = -1 then
        x_return_status    := 'E';
        x_msg_count        := 1;
        x_msg_data         := 'default_account value ' ||
                              v_DDP_Cat_Kyquy_Tbl(v_index).default_account ||
                              ' is not correct!';
        x_ddp_request_code := v_DDP_Cat_Kyquy_Tbl(v_index).ddp_request_code;
        goto STOP;
      elsif default_ccid = -2 then
        x_return_status    := 'E';
        x_msg_count        := 1;
        x_msg_data         := 'default_account value ' ||
                              v_DDP_Cat_Kyquy_Tbl(v_index).default_account || ' ' || verr;
        x_ddp_request_code := v_DDP_Cat_Kyquy_Tbl(v_index).ddp_request_code;
        goto STOP;
      end if;
    
      gInput(v_index).def_acct_id := default_ccid;
    end if;
    -- tiep tuc check data cho payment
    if not FPT_DDP_PAYMENT_PKG.validate(P_PAY_INFO => v_DDP_Cat_Kyquy_Tbl(v_index), 
                                        x_Input    => gInput(v_index),
                                        x_mess     => verr
                                        ) then  
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := x_msg_data || verr;
      x_ddp_request_code := v_DDP_Cat_Kyquy_Tbl(v_index).ddp_request_code;
      goto STOP;
    end if;
  	
    <<STOP>>
    v_index := v_index + 1;
    exit when x_return_status = 'E';
  end loop;
  
  
  if x_return_status = 'E' then			
    Delete fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'Cat_Kyquy'
			 and status = 'P';
    commit;
     /*rollback;*/
    return;
  end if;
  
    --> Sinh Invoice
    v_index := p_ddp_cat_kyquy_tbl.FIRST; 
    
  	WHILE v_index <= p_ddp_cat_kyquy_tbl.LAST LOOP
       --> import credit invoice
       begin
         import_credit_invocie(p_ddp_cat_kyquy_rec_all => v_DDP_Cat_Kyquy_Tbl(v_index),
                          p_Input                      => gInput(v_index),
													x_return_status              => x_return_status,
													x_msg_count                  => x_msg_count,
													x_msg_data                   => x_msg_data ,
													x_ddp_request_code           => x_DDP_Cat_Kyquy_Tbl_out(v_index).ddp_request_code,
                          x_request_id                 => v_request_id,
                          x_Invoice_batch_ID           => vInvoice_batch_ID,
                          x_Invoice_number             => vInvoice_number,
                          X_Invoice_id                 => vInvoice_id );
        end;
        
        gInput(v_index).org_id           := p_ddp_cat_kyquy_tbl(v_index).org_id ;
        gInput(v_index).invoice_batch_id := vInvoice_batch_ID;
        gInput(v_index).invoice_id       := vInvoice_id;
        gInput(v_index).ddp_request_code := p_ddp_cat_kyquy_tbl(v_index).ddp_request_code;
        -->Create Zero payment
        if x_return_status = 'S' then
          
          FPT_DDP_PAYMENT_PKG.Create_payment_zero(p_GIAM_KYQUY_INV_ID => vInvoice_id,
                                                  P_PAY_INFO          => v_DDP_Cat_Kyquy_Tbl(v_index),
                                                  p_Input             => gInput(v_index),
                                                  x_status            => x_return_status,
                                                  x_mess              => x_msg_data,
                                                  x_check_id          => vCheck_id);        
        end if;
        
        gInput(v_index).check_id := vCheck_id;         
        
    	v_index := v_index + 1;
		exit when x_return_status = 'E';
    end loop;
   
   -->Neu thanh cong se dinh khoan final va out put 
   if x_return_status = 'S' then
     for i in 1..gInput.count loop
       begin
          x_DDP_Cat_Kyquy_Tbl_out(i).X_invoice_batch_id := gInput(i).invoice_batch_id;
          x_DDP_Cat_Kyquy_Tbl_out(i).X_invoice_id := gInput(i).Invoice_id;
          x_DDP_Cat_Kyquy_Tbl_out(i).X_invoice_number := gInput(i).Invoice_id;
          x_DDP_Cat_Kyquy_Tbl_out(i).X_check_id := gInput(i).Check_id;
          x_DDP_Cat_Kyquy_Tbl_out(i).X_check_number := gInput(i).Check_id;
        
          -->Dinh khoan
          mo_global.set_policy_context('S',gInput(i).org_id);      
          v_retcode   := NULL;
          v_error_buf := NULL;  
          -->AP Invoice 
          ap_drilldown_pub_pkg.invoice_online_accounting 
                       (p_invoice_id         => gInput(i).Invoice_id,
                        p_accounting_mode    => 'F',        
                        p_errbuf             => v_error_buf,
                        p_retcode            => v_retcode,
                        p_calling_sequence   => 'FPT_DDP_CAT_KQ_PUB_V1.import_credit_invocie'
                       );
           commit;
           -->AP Payment
           ap_drilldown_pub_pkg.PAYMENT_ONLINE_ACCOUNTING
                       (p_check_id         => gInput(i).check_id,
                        p_accounting_mode  => 'F',
                        p_errbuf           => v_error_buf,
                        p_retcode          => v_retcode,
                        p_calling_sequence => 'FPT_DDP_CAT_KQ_PUB_V1.create_zero_payment');
            commit;
           
           -->Output
           insert into FPT_DDP_CAT_KYQUY
             (ddp_id,
              STT,
              x_Invoice_batch_ID,
              x_Invoice_number,
              X_Invoice_id,
              x_check_number,
              x_check_id,
              ddp_request_code)
           values
             (p_ddp_id,
              i,
              gInput(i).Invoice_batch_ID,
              gInput(i).Invoice_id,
              gInput(i).Invoice_id,
              gInput(i).check_id,
              gInput(i).check_id,
              gInput(i).ddp_request_code
              ); 
            commit;
          end;
       end loop;
   else
     -->Xoa du lieu
     for i in 1..gInput.count loop
       begin
         -->Xoa du lieu AP Invoice
         fpt_ddp_syn_pub.delete_ap_invoice(p_invoice_id  => gInput(i).invoice_id);
         -->Xoa du lieu AP Payment
         fpt_ddp_syn_pub.delete_ap_payment(p_check_id  => gInput(i).check_id);        
         commit;
       end;
     end loop;
     -->Xoa bang process and return
     Delete fpt_ddp_process
      where ddp_id = p_ddp_id
        and program = 'Cat_Kyquy'
        and status = 'P';     
        commit;
     return;
   end if;
    
    --> update trang thai ddp_id
   update fpt_ddp_process
      set Status = 'S',
          end_time = sysdate
    where ddp_id = p_ddp_id
      and program = 'Cat_Kyquy' ;
   commit;
   x_return_status    := 'S';
	 x_msg_count        := 1;
	 x_msg_data         := 'Import Success!!!';
      
 exception when others then      
      x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := sqlerrm;  
      update fpt_ddp_process
         set Status = 'E',
             end_time = sysdate
       where ddp_id = p_ddp_id
         and program = 'Cat_Kyquy' ;
      commit;    
end;

END FPT_DDP_CAT_KQ_PUB_V1 ;
/
