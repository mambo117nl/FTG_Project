CREATE OR REPLACE PACKAGE FPT_DDP_BL_INV_PUB_V1  AS
/* $Header: FPT_DDP_BL_INV_PUB_V1.pls 120.3 2005/07/19 18:56:53 repuri ship$ */
/*#
 * baolanh create  API
 * This API contains the procedures to create baolanh.
 * @rep:scope public
 * @rep:product AP
 * @rep:displayname Create FPT DDP baolanh API
 * @rep:category BUSINESS_ENTITY INV_REC_baolanh

*/
  /*****************************************************************************************
   This is a public API that caller will invoke. 
   It provides procedures for managing Salesreps, like
   create baolanh from other modules.
   Its main procedures are as following:
   create_ddp_baolanh_all
   ******************************************************************************************/
TYPE DDP_baolanh_line_type IS RECORD
  (
    LINE_AMOUNT number,
      GL_ACCOUNT    VARCHAR2(100),
      TAX_CODE  VARCHAR2(50),
      Description_line  ap_invoice_lines_all.description%type,
      --- DFF line
      Project_id  number
   );
   
TYPE DDP_baolanh_line_tbl_type IS TABLE OF DDP_baolanh_line_type INDEX BY BINARY_INTEGER;

 TYPE DDP_baolanh_Rec_Type IS RECORD (

      DDP_REQUEST_CODE  VARCHAR2(50),
      ORG_ID  NUMBER,
      --- invocie
      BATCH_NAME  ap_batches_v.BATCH_NAME%type,
      baolanh_DATE  VARCHAR2(50),
      INVOICE_TYPE  ap_invoices_all.invoice_type_lookup_code%type,
      VENDOR_ID     number,
      VENDOR_SITE_ID  number,
      AMOUNT  NUMBER,
      DESCRIPTION  ap_invoices_all.description%type,
      CURRENCY  ap_invoices_all.invoice_currency_code%type,
      RATE  NUMBER,
      INV_TERM  VARCHAR2(20),
      INV_PAYMENT_METHOD  VARCHAR2(20),
     -- DFF
      HOADON_TYPE ap_invoices_all.attribute3%type,
      INV_HOADON  VARCHAR2(150),
      SERI_HOADON VARCHAR2(150),
      KYHIEU_HOADON   VARCHAR2(150),
      HANGHOA VARCHAR2(150),
      --line
     /* GL_ACCOUNT    VARCHAR2(100),
      TAX_CODE  VARCHAR2(100),
      Description_line  VARCHAR2(100),
      --- DFF line
      Project_id  number*/
      DDP_baolanh_line_tbl DDP_baolanh_line_tbl_type
  );
  
  
TYPE DDP_baolanh_Tbl_Type IS TABLE OF DDP_baolanh_Rec_Type INDEX BY BINARY_INTEGER;


TYPE DDP_baolanh_Rec_Type_out IS RECORD
  ( 
      ddp_request_code         VARCHAR2(50),
   x_Invoice_batch_ID        number,
   x_Invoice_number         ap_invoices_all.invoice_num%type,
   X_Invoice_id              Number
   );
   
TYPE DDP_baolanh_Tbl_Type_out IS TABLE OF DDP_baolanh_Rec_Type_out INDEX BY BINARY_INTEGER;


/* Procedure to import baolanh to invoice and receipt 
  based on input values passed by calling routines. */
/*#
 * Create baolanh invocie and receipt API   
 * This procedure allows the user to create a baolanh record.
 * @param p_DDP_ID batch ID.


 * @param P_DDP_baolanh_Tbl baolanh record.
 
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
* @param x_DDP_baolanh_Tbl_out record out put
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create DDP baolanh API
 */ 
PROCEDURE  create_ddp_baolanh_all
  (   p_DDP_ID                     IN   VARCHAR2,
      P_DDP_baolanh_Tbl                  IN  DDP_baolanh_Tbl_Type,    
      x_return_status                  OUT NOCOPY    VARCHAR2,
      x_msg_count                      OUT NOCOPY    NUMBER,
      x_msg_data                       OUT NOCOPY    VARCHAR2,
      x_ddp_request_code         OUT NOCOPY VARCHAR2,
      x_DDP_baolanh_Tbl_out          OUT NOCOPY DDP_baolanh_Tbl_Type_out
  );
  

END FPT_DDP_BL_INV_PUB_V1;
/
CREATE OR REPLACE PACKAGE BODY FPT_DDP_BL_INV_PUB_V1  AS
/* $Header: FPT_DDP_BL_INV_PUB_V1.pls 120.3 2005/07/19 18:56:53 repuri ship $ */

  

  /* Package variables. */

 -- G_PKG_NAME         CONSTANT VARCHAR2(30) := 'FPT_DDP_KQ_IMP_PUB_V1';
g_group_id varchar2(100);
g_amount number;
function get_segment1(p_org_id number) return varchar2 is
    v_SEGMENT1 varchar2(10) ;
  begin
   select t.SEGMENT1
      into v_SEGMENT1
      from FPT_COMPANY_CODE_ORG t
     where t.ORG_ID = p_org_id
       and rownum = 1;
  
    return v_SEGMENT1;
  exception
    when others then
      return - 1;
  end;
  
function get_SOB_ID(p_org_id number) return number is
    v_SET_OF_BOOKS_ID number;
  begin
    select t.SET_OF_BOOKS_ID
      into v_SET_OF_BOOKS_ID
      from fpt_org_company_v t
     where t.ORG_ID = p_org_id
       and rownum = 1;
  
    return v_SET_OF_BOOKS_ID;
  exception
    when others then
      return - 1;
  end;
  
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
      from FPT_COMPANY_CODE_ORG t
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
      FROM AP_TERMS_VL
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
FUNCTION check_project_code(p_ou_id in NUMBER, p_project_id in number) RETURN Boolean IS
    v_count NUMBER;
  BEGIN
       SELECT count(1)
          INTO v_count
           FROM DEV.FPT_PM_PROJECTS h  
         WHERE h.org_id = p_ou_id
           AND h.project_id = p_project_id
          
           ;
  if nvl(v_count,0) = 0 then
    return false;
    else
   RETURN true;
   end if;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN false;
  END;
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

FUNCTION check_tax_code(p_tax_code varchar2) return boolean is
	v_count number;

BEGIN
	SELECT count(1)
		into v_count
		FROM ZX_RATES_VL r
	 WHERE r.TAX_RATE_CODE = TRIM(upper(p_tax_code));

	if nvl(v_count, 0) = 0 then
		return false ;
    else
			return true;
	end if;

EXCEPTION
	WHEN OTHERS THEN
		return false;
	
END;    

  procedure ap_create_accounting(p_invoice_id number) is


        ln_retcode  varchar2(100);
        lv_error_buf  varchar2(100);
   BEGIN
     
      ln_retcode   := NULL;
      lv_error_buf := NULL;

      ap_drilldown_pub_pkg.invoice_online_accounting 
         (
           p_invoice_id         => p_invoice_id,
           p_accounting_mode    => 'F',        
           p_errbuf             => lv_error_buf,
           p_retcode            => ln_retcode,
           p_calling_sequence   => 'ddp_baolanh_import_pub_v1.import_invoice'
         );
         
 commit;
end;
-- Author  : Hungdd13
-- Created : 3/4/2022 5:09:20 PM
-- Purpose : AR_Create_Accounting
procedure ar_Create_Accounting(p_CASH_RECEIPT_ID number) is

	l_accounting_batch_id number; --Out
	p_errbuf              varchar2(100); --Out
	p_retcode             varchar2(100);
	l_request_id          number;
	v_CASH_RECEIPT_ID     number := p_CASH_RECEIPT_ID;
	v_ledger_id           number;
  v_legal_entity_id     number;
  v_org_id              number;
	l_event_source_info   XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;

begin
	select t.legal_entity_id, t.org_id
		into v_legal_entity_id, v_org_id
		from ar_cash_receipts_all t
	 where t.cash_receipt_id = v_CASH_RECEIPT_ID
		 and rownum = 1;
	v_ledger_id := get_SOB_ID(v_org_id);

	begin
		--mo_global.init('AR');
		mo_global.set_policy_context('S', v_org_id);
		/*fnd_global.apps_initialize(user_id      => 0,
															 resp_id      => 20678,
															 resp_appl_id => 222);*/
	
		l_event_source_info.source_application_id := 222;
		l_event_source_info.application_id        := 222;
		l_event_source_info.legal_entity_id       := v_legal_entity_id;
		l_event_source_info.ledger_id             := get_SOB_ID(v_org_id);
		l_event_source_info.entity_type_code      := 'RECEIPTS';
		l_event_source_info.transaction_number    := v_CASH_RECEIPT_ID; --RECEIPT_number  draft 8642357
		l_event_source_info.source_id_int_1       := v_CASH_RECEIPT_ID; --CASH_RECEIPT_ID  862478

	
		XLA_ACCOUNTING_PUB_PKG.ACCOUNTING_PROGRAM_DOCUMENT(P_event_source_info   => l_event_source_info,
																											 P_entity_id           => null,
																											 P_accounting_flag     => 'Y',
																											 P_accounting_mode     => 'F',
																											 P_transfer_flag       => 'N',
																											 P_gl_posting_flag     => 'N',
																											 P_offline_flag        => 'N',
																											 P_accounting_batch_id => l_accounting_batch_id, --Out
																											 P_errbuf              => p_errbuf, --Out
																											 P_retcode             => p_retcode, --Out
																											 P_request_id          => l_request_id --Out
																											 );
	
		
		commit;
	end;

exception
	when others then
		dbms_output.put_line('Request set submission failed ? unknown error: ' ||
												 sqlerrm);
END;

/*procedure AR_Create_Accounting (p_ledge_id number) is

v_request_id VARCHAR2(100) ;
v_ledge_id number;
BEGIN

Fnd_Global.apps_initialize(0,20678,222);
v_ledge_id := p_ledge_id;
 \*select t.SET_OF_BOOKS_ID
      into v_ledge_id
      from fpt_org_company_v t
     where t.ORG_ID = p_org_id
       and rownum = 1;*\
           
v_request_id:=fnd_request.submit_request ('XLA',
                                         'XLAACCPB',
                                         '',
                                         '', 
                                         FALSE,
                                         222,
                                         v_ledge_id,
                                         222,
                                         'Y',
                                         v_ledge_id,
                                         '',
                                         to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'),
                                         'Y',
                                         'Y',
                                         'F',  -- Final
                                         'Y',
                                         'N',
                                         'N',
                                         'N',
                                         '',
                                         '',
                                         '',
                                         '',
                                         'N');  

dbms_output.put_line('Request submitted. ID = ' || v_request_id);

commit ;

exception
when others then
dbms_output.put_line('Request set submission failed ? unknown error: ' || sqlerrm);
END;*/


    
procedure validate_invoice_submit(p_invoice_id number default null)is
  
    v_req_id     number;
    v_result     boolean;
    v_phase_out  varchar2(240);
    v_status     varchar2(240);
    v_dev_phase  varchar2(240);
    v_dev_status varchar2(240);
    v_message    varchar2(240);
    v_invoice_id number := p_invoice_id;
  begin
  
    fnd_global.apps_initialize(user_id      => 0,
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
  
    v_result := fnd_concurrent.wait_for_request(v_req_id -- request id
                                               ,1 -- interval
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
   
    fnd_global.apps_initialize(user_id      => 0,
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
                                                   1,
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
   
PROCEDURE import_invocie(p_ddp_baolanh_rec_all in ddp_baolanh_rec_type,
                          x_return_status     out nocopy varchar2,
                          x_msg_count         out nocopy number,
                          x_msg_data          out nocopy varchar2,
                          x_ddp_request_code  out nocopy varchar2,
                          x_request_id  out nocopy number,
                          x_Invoice_batch_ID      out nocopy number,
                          x_Invoice_number      out nocopy   ap_invoices_all.invoice_num%type,
                          X_Invoice_id     out nocopy         Number) is

  v_ddp_baolanh_rec_all ddp_baolanh_rec_type := p_ddp_baolanh_rec_all;
  v_erros_message     varchar2(200);
  verr                varchar2(200);
  v_invoice_id        ap_invoices_all.invoice_id%TYPE ;
  v_batch_id           ap_invoices_all.batch_id%TYPE ;
  v_invoice_num        ap_invoices_all.invoice_num%type;
  v_invoice_line_id   ap_invoice_lines_interface.invoice_line_id%type;
  v_batch_name         varchar2(100);
  v_group_id           ap_invoices_interface.group_id%type ;
  v_count             number;
  v_vendor_id         po_vendor_sites_all.vendor_id%type;
  v_vendor_site_id    po_vendor_sites_all.vendor_site_id%type;
  v_termid            ap_terms.term_id%type;
  v_org_id            number;
  v_user_id           number := fnd_profile.value('user_id');
  inv_ccid            number;
  default_ccid        number;
  v_source            varchar2(100) := 'MANUAL INVOICE ENTRY';
  v_request_id        number;
  v_ccid              number;
  v_tax_rate   ap_invoice_lines_interface.tax_rate%type       ;
  v_project_code     varchar2(100);
  v_amount number;
   v_DDP_baolanh_line_tbl DDP_baolanh_line_tbl_type := p_ddp_baolanh_rec_all.DDP_baolanh_line_tbl;
begin
  x_return_status := 'S';
  v_erros_message := null;
 --  v_groupid := v_ddp_baolanh_rec_all.BATCH_NAME;

 select  ap_invoices_interface_s.nextval into v_invoice_id from dual;
 --select ap_invoice_lines_interface_s.nextval into v_invoice_line_id from dual;
 v_invoice_num := 'KQ-'||to_char(v_invoice_id);
 v_org_id := v_ddp_baolanh_rec_all.ORG_ID;
 -- get group_id 
   v_group_id := v_ddp_baolanh_rec_all.BATCH_NAME || '.' || v_invoice_id;
  --> get term_id
  v_termid := get_term_id(v_ddp_baolanh_rec_all.inv_term);
 -- v_vendor_id := v_ddp_baolanh_rec_all.VENDOR_ID;
  v_vendor_site_id := v_ddp_baolanh_rec_all.VENDOR_SITE_ID;
  -- get vendor_id,vendor_site_id
  /*select  b.VENDOR_ID
    into  v_vendor_id
    from po_vendors b
   where b.segment1 = v_ddp_baolanh_rec_all.vendor_number
     and rownum =1;*/
   v_vendor_id := v_ddp_baolanh_rec_all.VENDOR_ID;
  /* -- get project code
   begin
   SELECT project_code
          INTO v_project_code
           FROM DEV.FPT_PM_PROJECTS h  
         WHERE h.org_id = v_ddp_baolanh_rec_all.org_id
           AND h.project_id = v_ddp_baolanh_rec_all.project_id
           and rownum=1;
  exception when others then
    v_project_code := null;
  end;         
  -- get GL_ACCOUNT
  if v_ddp_baolanh_rec_all.GL_ACCOUNT is not null then
    default_ccid := get_ccid_seg1(p_all_segments  => v_ddp_baolanh_rec_all.GL_ACCOUNT,
                                  p_org_id        => v_ddp_baolanh_rec_all.org_id,
                                  p_error_message => verr);
    if default_ccid = -1 then
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'GL_ACCOUNT value ' ||
                            v_ddp_baolanh_rec_all.GL_ACCOUNT ||
                            ' is not correct!';
      x_ddp_request_code := v_ddp_baolanh_rec_all.ddp_request_code;
      return;
    elsif default_ccid = -2 then
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'GL_ACCOUNT value ' ||
                            v_ddp_baolanh_rec_all.GL_ACCOUNT || ' ' || verr;
      x_ddp_request_code := v_ddp_baolanh_rec_all.ddp_request_code;
      return;
    end if;
  end if;*/

  -- l?y ccid theo vendor site
	select pa.ACCTS_PAY_CODE_COMBINATION_ID
		into v_ccid
		from po_vendors pov, po_vendor_sites_all pa
	 where pov.VENDOR_ID = pa.VENDOR_ID
		 and pov.VENDOR_ID = v_vendor_id
		 and pa.VENDOR_SITE_ID = v_ddp_baolanh_rec_all.VENDOR_SITE_ID
     and pa.ORG_ID = v_org_id
     and rownum =1; 
     
     --------   
   begin
     v_amount := 0;
     -- lay tong line cho amount header
      for i in 1 .. v_DDP_baolanh_line_tbl.count loop
        v_amount := v_amount + v_DDP_baolanh_line_tbl(i).LINE_AMOUNT;
        end loop;
    insert into ap_invoices_interface
      (invoice_id,
       invoice_num,
       invoice_type_lookup_code,
       invoice_DATE,
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
       ATTRIBUTE3,  -- loai hoa don
       attribute11,    -- so hoa don
       ATTRIBUTE2, -- so seri hoa don
       ATTRIBUTE4, -- kyhieu hoa don
       ATTRIBUTE9,    -- tên hang hoa
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
       'STANDARD',
       to_date(v_ddp_baolanh_rec_all.baolanh_DATE,'DD/MM/YYYY'),
       v_vendor_id,
       v_vendor_site_id,
       v_amount, --v_ddp_baolanh_rec_all.AMOUNT,
       v_ddp_baolanh_rec_all.CURRENCY,
       v_ddp_baolanh_rec_all.RATE,
       'User', 
       to_date(v_ddp_baolanh_rec_all.baolanh_DATE,'DD/MM/YYYY'),
       v_termid,
       v_ddp_baolanh_rec_all.inv_term,
       v_ddp_baolanh_rec_all.description,
       sysdate,
       v_user_id,
       sysdate,
       v_user_id,
       'Purchase Invoice', 
       v_ddp_baolanh_rec_all.ddp_request_code, -- danh dau invoice 
       v_ddp_baolanh_rec_all.HOADON_TYPE,  -- loa hoa don
       v_ddp_baolanh_rec_all.inv_hoadon, --att11
       v_ddp_baolanh_rec_all.SERI_HOADON,
       v_ddp_baolanh_rec_all.KYHIEU_HOADON,
       v_ddp_baolanh_rec_all.HANGHOA,
       nvl(v_ddp_baolanh_rec_all.inv_payment_method,'CHECK'),
       v_source,
       null, 
       to_date(v_ddp_baolanh_rec_all.baolanh_DATE,'DD/MM/YYYY'),
       v_ccid, -- inv_ccid, 
       v_org_id,
       v_group_id);
       commit;
  end;
  
  begin
    for i in 1 .. v_DDP_baolanh_line_tbl.count loop
     -- get project code
   begin
   SELECT project_code
          INTO v_project_code
           FROM DEV.FPT_PM_PROJECTS h  
         WHERE h.org_id = v_ddp_baolanh_rec_all.org_id
           AND h.project_id = v_DDP_baolanh_line_tbl(i).project_id
           and rownum=1;
  exception when others then
    v_project_code := null;
  end;         
  -- get GL_ACCOUNT
  if v_DDP_baolanh_line_tbl(i).GL_ACCOUNT is not null then
    default_ccid := get_ccid_seg1(p_all_segments  => v_DDP_baolanh_line_tbl(i).GL_ACCOUNT,
                                  p_org_id        => v_ddp_baolanh_rec_all.org_id,
                                  p_error_message => verr);
  end if;
  
    insert into ap_invoice_lines_interface
      (invoice_id,
       invoice_line_id,
       line_number,
       line_type_lookup_code,
       amount,
       accounting_date,
       description,
       dist_code_combination_id,
       --tax
    tax_classification_code,
    /*tax_regime_code,
    tax,
    tax_status_code,
    tax_jurisdiction_code, */                  
  --  tax_rate,
    
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       org_id,
       attribute_category,
       attribute10)
    values
      (v_invoice_id,
       ap_invoice_lines_interface_s.nextval, --v_invoice_line_id,
       i,
       'ITEM',
       v_DDP_baolanh_line_tbl(i).LINE_AMOUNT,
       to_date(v_ddp_baolanh_rec_all.baolanh_DATE,'DD/MM/YYYY'),
       v_DDP_baolanh_line_tbl(i).Description_line,
       default_ccid,
       ---- tax
       nvl(v_DDP_baolanh_line_tbl(i).tax_code,'IP-KHONG CHIU THUE'),     
       sysdate,
       v_user_id,
       sysdate,
       v_user_id,
       v_org_id,
       'Purchase Invoice',
       v_DDP_baolanh_line_tbl(i).Project_id
       );
  
    commit;
   end loop; 
   
    exception when others then
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'loi iinsert data';
      x_ddp_request_code := v_ddp_baolanh_rec_all.ddp_request_code;
      return;
    end;
  

  -- sumit request import 
  if v_ddp_baolanh_rec_all.BATCH_NAME is not null then
    begin
      v_request_id := submit_payables_import(pin_org_id     => v_org_id,
                                             piv_source     => v_source,
                                             piv_group_id   => v_group_id, -- batch_name.Invoice_id
                                             piv_batch      => v_ddp_baolanh_rec_all.BATCH_NAME
                                       );
     end;
  else
     begin
      v_request_id := submit_payables_import(pin_org_id     => v_org_id,
                                             piv_source     => v_source,
                                             piv_group_id   => v_group_id, -- batch_name.Invoice_id
                                             piv_batch      => ''
                                       );
     end;
     end if;
    if v_request_id > 0 then
     
      select invoice_id, batch_id
        into v_invoice_id, v_batch_id
        from ap_invoices_all
       where invoice_num = v_invoice_num; 
      --------
       update ap_invoices_all t
       set t.invoice_num = to_char(t.invoice_id)
       where t.invoice_id =  v_invoice_id;
       commit;
         --------- update batch
        update ap_batches_all t
       set t.org_id = v_org_id
       where t.batch_id  =  v_batch_id;
       commit;
       ---------
           begin
       --validate invoice
           validate_invoice_submit(p_invoice_id => v_invoice_id);
           end;
           -- create accounting final
        /*   declare
           ln_retcode  varchar2(100);
        lv_error_buf  varchar2(100);
           BEGIN
 
        ln_retcode   := NULL;
        lv_error_buf := NULL;
 
        ap_drilldown_pub_pkg.invoice_online_accounting 
           (
             p_invoice_id         => v_invoice_id,
             p_accounting_mode    => 'F',        
             p_errbuf             => lv_error_buf,
             p_retcode            => ln_retcode,
             p_calling_sequence   => 'ddp_baolanh_import_pub_v1.import_invoice'
           );
         end;*/
         
      x_return_status    := 'S';
      x_msg_count        := 1;
      x_msg_data         := 'Request Import Success';
      x_ddp_request_code := v_ddp_baolanh_rec_all.DDP_REQUEST_CODE;
      x_request_id := v_request_id;
      x_Invoice_batch_ID     := v_batch_id;
      x_Invoice_number      := to_char(v_invoice_id);
      X_Invoice_id     := v_invoice_id;
      else 
        rollback;
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'Fail to request Import invocie';
      x_ddp_request_code := v_ddp_baolanh_rec_all.DDP_REQUEST_CODE;
      
    
    end if;
    
  
    exception
  when others then
    x_return_status    := 'E';
    x_msg_count        := 1;
    x_msg_data         := sqlerrm;
    x_ddp_request_code := v_ddp_baolanh_rec_all.ddp_request_code;
    rollback;
    return;
end;


PROCEDURE  create_ddp_baolanh_all
  (   p_ddp_id                     in   varchar2,
      p_ddp_baolanh_tbl                  in  ddp_baolanh_tbl_type,    
      x_return_status                  out nocopy    varchar2,
      x_msg_count                      out nocopy    number,
      x_msg_data                       out nocopy    varchar2,
      x_ddp_request_code         out nocopy varchar2,
      x_DDP_baolanh_Tbl_out          OUT NOCOPY DDP_baolanh_Tbl_Type_out
  ) is

  v_erros_message     varchar2(200);
  v_index number := p_ddp_baolanh_tbl.first;
  v_number number :=0;
  v_invoice_id    number;
  v_user_id        number := fnd_profile.value('user_id');
  v_ddp_request_code varchar(50);
  v_ddp_baolanh_tbl ddp_baolanh_tbl_type := p_ddp_baolanh_tbl;
  v_DDP_baolanh_line_tbl DDP_baolanh_line_tbl_type;
  v_request_id number;
  inv_ccid number;
  default_ccid number;
  rec_ccid number;
  v_count number;
  verr                varchar2(200);
  v_start_date date ;
  v_ddp_id number;
  v_status varchar2(10);
  v_amount number := 0;
 
begin
--> save point 
--  SAVEPOINT ;
  v_start_date := sysdate;
 x_return_status := 'S';
  g_group_id := p_DDP_ID;
    --> check ddp_id in process
  begin
    select count(1)
      into v_count
      from fpt_ddp_process
     where ddp_id = p_ddp_id
       and program = 'baolanh_Import'
       and status = 'P';
  exception
    when others then
      v_count := null;
  end;   
   if nvl(v_count,0) >0 /*and v_status = 'P'*/ then
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
       and program = 'baolanh_Import'
       and status = 'S';
  exception
    when others then
      v_count := null;
  end;   
    if nvl(v_count,0) >0 /*and v_status = 'S'*/ then
    -- tra du lieu khi goi lai ddp_id da chay thanh cong 
      for i in 1 .. p_ddp_baolanh_tbl.COUNT LOOP 
        begin
          select 
                  x_Invoice_batch_ID,
                  x_Invoice_number,
                  X_Invoice_id,
                  ddp_request_code
                 
            into x_DDP_baolanh_Tbl_out(i).x_Invoice_batch_ID,
                  x_DDP_baolanh_Tbl_out(i).x_Invoice_number,
                  x_DDP_baolanh_Tbl_out(i).X_Invoice_id ,      
                  x_DDP_baolanh_Tbl_out(i).ddp_request_code
            from FPT_DDP_baolanh
           where ddp_id = p_ddp_id
             and stt = i;
        exception
          when others then
          null;
        end;         
      end loop;
     
      x_return_status := 'S';
      x_msg_count     := 1;
      x_msg_data      := 'Ap baolanh Success!!!';
      return;
     end if;
      
  --> insert ddp_id
  insert into fpt_ddp_process
    (ddp_id, program, status, start_time)
  values
    (p_ddp_id, 'baolanh_Import', 'P', sysdate);
  commit;
    
  -- check data input
  WHILE v_index <= P_DDP_baolanh_Tbl.LAST LOOP
    v_DDP_baolanh_line_tbl := v_DDP_baolanh_Tbl(v_index).DDP_baolanh_line_tbl;
    --> check term_id
  if get_term_id(v_DDP_baolanh_Tbl(v_index).inv_term) = -1 then
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'inv_term not exists.';
      x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;
      goto STOP;
   end if;
  /* --> check tax code
   for i in v_DDP_baolanh_line_tbl.count loop
   if v_DDP_baolanh_line_tbl(i).TAX_CODE is not null and check_tax_code(v_DDP_baolanh_line_tbl(i).TAX_CODE) = false then
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'tax code not exists.';
      x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;
      goto STOP;
   end if;*/
   
   
 --  end loop;
   -- check mo ky GL
   if check_period(v_DDP_baolanh_Tbl(v_index).org_id,to_date(v_DDP_baolanh_Tbl(v_index).baolanh_DATE,'DD/MM/YYYY')) = -1 then
     x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'period not open or org_id not correct!!!';
      x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;
      goto STOP;
     end if;
     
  -- check vendor_id,vendor_site_id
  select count(*)
    into v_count
    from po_vendor_sites_all a, po_vendors b
   where a.VENDOR_ID = b.VENDOR_ID
     and b.VENDOR_ID = v_DDP_baolanh_Tbl(v_index).vendor_id
     and a.vendor_site_id = v_DDP_baolanh_Tbl(v_index).vendor_site_id;
    -- and a.ORG_ID = v_DDP_baolanh_Tbl(v_index).org_id;

  if nvl(v_count, 0) = 0 then
    x_return_status    := 'E';
    x_msg_count        := 1;
    x_msg_data         := x_msg_data ||
                          'the vendor site id is not for the vendor_id!!!';
    x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;                      
    goto STOP;
  end if;
  
   -- check org_id,vendor_site_id
  select count(*)
    into v_count
    from po_vendor_sites_all a
   where a.vendor_site_id = v_DDP_baolanh_Tbl(v_index).vendor_site_id
    and a.ORG_ID = v_DDP_baolanh_Tbl(v_index).org_id;

  if nvl(v_count, 0) = 0 then
    x_return_status    := 'E';
    x_msg_count        := 1;
    x_msg_data         := x_msg_data ||
                          'the vendor site id is not for the org_id!!!';
    x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;                      
    goto STOP;
  end if;
  
  -- check payment method code
  select count(*)
    into v_count
    from iby_payment_methods_vl
   where payment_method_code = v_DDP_baolanh_Tbl(v_index).inv_payment_method;
  if nvl(v_count, 0) = 0 then
    x_return_status    := 'E';
    x_msg_count        := 1;
    x_msg_data         := x_msg_data || 'wrong payment_method';
    x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;
    goto STOP;
  end if;
  
   --> check tax code
   for i in 1 .. v_DDP_baolanh_line_tbl.count loop
   if v_DDP_baolanh_line_tbl(i).TAX_CODE is not null and check_tax_code(v_DDP_baolanh_line_tbl(i).TAX_CODE) = false then
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'tax code not exists.';
      x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;
      goto STOP;
   end if;
  -- check GL_ACCOUNT
  if v_DDP_baolanh_line_tbl(i).GL_ACCOUNT is not null then
    default_ccid := get_ccid_seg1(p_all_segments  => v_DDP_baolanh_line_tbl(i).GL_ACCOUNT,
                                  p_org_id        => v_DDP_baolanh_Tbl(v_index).org_id,
                                  p_error_message => verr);
    if default_ccid = -1 then
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'GL_ACCOUNT value ' ||
                            v_DDP_baolanh_line_tbl(i).GL_ACCOUNT ||
                            ' is not correct!';
      x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;
      goto STOP;
    elsif default_ccid = -2 then
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'GL_ACCOUNT value ' ||
                            v_DDP_baolanh_line_tbl(i).GL_ACCOUNT || ' ' || verr;
      x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;
      goto STOP;
    end if;
  end if;
  -- check project_code
   if v_DDP_baolanh_line_tbl(i).PROJECT_ID is not null and check_project_code(p_ou_id => v_DDP_baolanh_Tbl(v_index).org_id, p_project_id => v_DDP_baolanh_line_tbl(i).PROJECT_ID) = false then
      x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := 'Project_id not exsits !!!';
			x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;
			goto STOP;
     end if;    
     
     v_amount := v_amount + v_DDP_baolanh_line_tbl(i).LINE_AMOUNT;
  end loop;
  -- check so tien line va header
 /* if v_DDP_baolanh_Tbl(v_index).AMOUNT is not null and v_amount != v_DDP_baolanh_Tbl(v_index).AMOUNT then
    x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := 'Total GL_AMOUNT of line not equal to AMOUNT !!!';
			x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;
      goto STOP;
   
     end if;*/
     
      
  
      <<STOP>>
      v_index := v_index + 1;
      exit when x_return_status = 'E';
    end loop;
    
    if x_return_status = 'E' then     
       rollback;
       Delete from fpt_ddp_process
        where ddp_id = p_ddp_id
          and program = 'baolanh_Import'
          ;
       commit;
       return;
    end if;
   
    -- insert bang interface
    v_index := P_DDP_baolanh_Tbl.FIRST;                                       
    WHILE v_index <= P_DDP_baolanh_Tbl.LAST LOOP
      -- import invoice
       begin
         import_invocie(p_ddp_baolanh_rec_all => v_DDP_baolanh_Tbl(v_index),
                          x_return_status   => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data ,
                          x_ddp_request_code  =>  x_DDP_baolanh_Tbl_out(v_index).ddp_request_code,
                          x_request_id => v_request_id,
                          x_Invoice_batch_ID   => x_DDP_baolanh_Tbl_out(v_index).x_Invoice_batch_ID,
                          x_Invoice_number    =>  x_DDP_baolanh_Tbl_out(v_index).x_Invoice_number,
                          X_Invoice_id     =>  x_DDP_baolanh_Tbl_out(v_index).X_Invoice_id );
        end;
        
        --mo_global.set_policy_context('S', v_DDP_baolanh_Tbl(v_index).ORG_ID); 
         -- import reciept  
        if x_return_status != 'S' then
        
           rollback;
             x_return_status := 'E';
             x_msg_count        := 1;
             x_msg_data         := 'Invocie not created!';
             x_ddp_request_code := v_DDP_baolanh_Tbl(v_index).ddp_request_code;
         
        end if;
       
       -- luu du lieu 
      /*  if x_return_status = 'S' then
         insert into FPT_DDP_baolanh
           (ddp_id,
            STT,
            x_Invoice_batch_ID,
            x_Invoice_number,
            X_Invoice_id,
            ddp_request_code)
         values
           (p_ddp_id,
            v_index,
            x_DDP_baolanh_Tbl_out(v_index).x_Invoice_batch_ID,
            x_DDP_baolanh_Tbl_out(v_index).x_Invoice_number,
            x_DDP_baolanh_Tbl_out(v_index).X_Invoice_id,
            x_DDP_baolanh_Tbl_out(v_index).ddp_request_code
            ); 
   
       end if;*/
       
    
      v_index := v_index + 1;
      exit when x_return_status <> 'S';
    end loop;
    
   if x_return_status <> 'S' then     
     rollback;
       -- Xoa du lieu tra ve
        for i in 1 .. x_DDP_baolanh_Tbl_out.COUNT LOOP 
          x_DDP_baolanh_Tbl_out.delete(i);
          end loop;
     Delete from fpt_ddp_process
       where ddp_id = p_ddp_id
         and program = 'baolanh_Import'
         ;
     return;
     else
       -- create accounting
       
        for i in 1 .. x_DDP_baolanh_Tbl_out.COUNT LOOP 
          -- create account AP
          begin
           mo_global.init('SQLAP');
	    	  --mo_global.set_policy_context('S', v_org_id);
          fnd_global.apps_initialize(user_id      => 0,
															 resp_id      => 20639,
															 resp_appl_id => 200);
          ap_create_accounting(x_DDP_baolanh_Tbl_out(i).X_Invoice_id); 
          
         end;
         -- luu du lieu 
         begin
           insert into FPT_DDP_baolanh
           (ddp_id,
            STT,
            x_Invoice_batch_ID,
            x_Invoice_number,
            X_Invoice_id,
            ddp_request_code)
         values
           (p_ddp_id,
            i,
            x_DDP_baolanh_Tbl_out(i).x_Invoice_batch_ID,
            x_DDP_baolanh_Tbl_out(i).x_Invoice_number,
            x_DDP_baolanh_Tbl_out(i).X_Invoice_id,
            x_DDP_baolanh_Tbl_out(i).ddp_request_code
            ); 
           end;
        end loop;
   end if;
         
   --> update trang thai ddp_id
   update fpt_ddp_process
      set Status = 'S',
          end_time = sysdate
    where ddp_id = p_ddp_id
      and program = 'baolanh_Import'
      and status = 'P';
    
    commit;
    x_return_status    := 'S';
    x_msg_count        := 1;
    x_msg_data         := 'Ap baolanh Success!!!';
      
 exception when others then
      rollback;
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := sqlerrm;
      Delete from fpt_ddp_process
       where ddp_id = p_ddp_id
         and program = 'baolanh_Import'
         and status = 'P';
      commit;
end;

END FPT_DDP_BL_INV_PUB_V1 ;
/
