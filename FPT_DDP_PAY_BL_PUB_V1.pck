CREATE OR REPLACE PACKAGE FPT_DDP_PAY_BL_PUB_V1  AS
/* $Header: FPT_DDP_PAY_BL_PUB_V1.pls 120.3 2005/07/19 18:56:53 repuri ship$ */
/*#
 * Salesperson create and update API
 * This API contains the procedures to insert and update baolanh record.
 * @rep:scope public
 * @rep:product AP
 * @rep:displayname Create DDP pay baolanh API
 * @rep:category BUSINESS_ENTITY INV_pay_baolanh_IMPORT

*/
  /*****************************************************************************************
   This is a public API that caller will invoke. 
   It provides procedures for managing Salesreps, like
   create and update Salesreps from other modules.
   Its main procedures are as following:
   create_ddp_pay_baolanh_all
   ******************************************************************************************/


  
 TYPE DDP_pay_baolanh_Rec_Type IS RECORD (

      DDP_REQUEST_CODE  VARCHAR2(50),
      ORG_ID  NUMBER,
     -- Pay_Type  VARCHAR2(100),
      Pay_date VARCHAR2(100),
     -- VENDOR_ID     number,
    --  VENDOR_SITE_ID  number,
      PAY_AMOUNT  NUMBER,
      PAY_DESCRIPTION  ap_checks_all.description%type,
      PAY_CURRENCY  VARCHAR2(100),
      PAY_RATE  NUMBER,
      --RATE_TYPE  VARCHAR2(100),
      --RATE_DATE   VARCHAR2(100),
      Bank_account_name VARCHAR2(100),
      --- DFF
      PAY_SOPHIEU   VARCHAR2(240), --ATTRIBUTE3
      LYDO    VARCHAR2(100), --ATTRIBUTE4
      INVOICE_ID number
     -- Payment_Amount  VARCHAR2(100)          
  );
  
  
TYPE DDP_pay_baolanh_Tbl_Type IS TABLE OF DDP_pay_baolanh_Rec_Type INDEX BY BINARY_INTEGER;


TYPE DDP_pay_baolanh_Rec_Type_out IS RECORD
  (
   ddp_request_code         VARCHAR2(50),
   x_check_number      ap_checks_all.check_number%type,
   X_check_id             Number
   );
   
TYPE DDP_pay_baolanh_Tbl_Type_out IS TABLE OF DDP_pay_baolanh_Rec_Type_out INDEX BY BINARY_INTEGER;



/* Procedure to import Credit baolanh to invoice and receipt 
  based on input values passed by calling routines. */
/*#
 * Create pay baolanh invocie and receipt API   
 * This procedure allows the user to create a baolanh record.
 * @param p_DDP_ID batch ID.
 * @param P_DDP_pay_baolanh_Tbl baolanh record.
 * @param x_return_status A code indipaying whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_msg_count An integer indipaying the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @param x_msg_data A character string containing message text.
 * Refer to the package description above for more information
 * about this parameter and a list of valid values.
 * @param x_ddp_request_code   ddp_request_code loi
 * @param x_DDP_pay_baolanh_Tbl_out record out put
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create DDP pay baolanh API
 */ 
PROCEDURE  create_ddp_pay_baolanh_all
  (   p_DDP_ID                     IN   VARCHAR2,
      P_DDP_pay_baolanh_Tbl                  IN  DDP_pay_baolanh_Tbl_Type,    
      x_return_status                  OUT NOCOPY    VARCHAR2,
      x_msg_count                      OUT NOCOPY    NUMBER,
      x_msg_data                       OUT NOCOPY    VARCHAR2,
      x_ddp_request_code         OUT NOCOPY VARCHAR2,
      x_DDP_pay_baolanh_Tbl_out          OUT NOCOPY DDP_pay_baolanh_Tbl_Type_out
  );
  

END FPT_DDP_PAY_BL_PUB_V1;
/
CREATE OR REPLACE PACKAGE BODY FPT_DDP_PAY_BL_PUB_V1  AS
/* $Header: FPT_DDP_PAY_BL_PUB_V1.pls 120.3 2005/07/19 18:56:53 repuri ship $ */

  

  /* Package variables. */

--G_PKG_NAME         CONSTANT VARCHAR2(30) := 'FPT_DDP_pay_KQ_PUB_V1';
g_group_id varchar2(100);

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
  
   /* V_RETURN := FND_FLEX_EXT.GET_COMBINATION_ID(APPLIpayION_SHORT_NAME => 'SQLGL',
                                                KEY_FLEX_CODE          => 'GL#',
                                                STRUCTURE_NUMBER       => V_COA_ID,
                                                VALIDATION_DATE        => SYSDATE,
                                                N_SEGMENTS             => 8,
                                                SEGMENTS               => V_SEGMENTS,
                                                COMBINATION_ID         => V_COMBINATION_ID,
                                                DATA_SET               => NULL);
  */
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
FUNCTION ck_invoice_id(P_invoice_id number, p_org_id number) RETURN boolean IS
    v_count NUMBER;
	BEGIN
		SELECT count(1)
			INTO v_count
			FROM ap_invoices_all
		 WHERE invoice_id = P_invoice_id
       and org_id = p_org_id
			 ;
	
		IF NVL(v_count, 0) = 0 THEN
			RETURN false;
    END IF;
    RETURN true;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN false;
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
 

 FUNCTION check_pay_amount(p_invoice_id number, p_amount number) return number is
	v_status number;
  
begin
	select count(*)
		into v_status
		from AP.AP_PAYMENT_SCHEDULES_ALL t
	 where t.invoice_id = p_invoice_id
   and t.amount_remaining >= p_amount;

	if nvl(v_status, 0) = 0 then
		return - 1;
	end if;
  
	return v_status;
exception
	when others then
		return - 1;
end;

/*procedure ap_payment_create(p_invocie_id      number,
														p_bank_account_id number,
														p_amount          number,
														p_check_id        out nocopy number,
                            p_check_number    out nocopy ap_checks.check_number%type,
														x_return_status   out nocopy varchar2,
														x_msg_count       out nocopy number,
														x_msg_data        out nocopy varchar2
														
														) is
	v_check_id            number := '';
	v_invoice_id          number := p_invocie_id;
	v_bank_account_id     number := p_bank_account_id;
	v_accounting_event_id number;
	v_amount              number := p_amount;
	type l_invoice_id is table of number index by binary_integer;
	t_invoice_id l_invoice_id;

begin

	\*apps.mo_global.init('SQLAP');
	--
	apps.fnd_global.apps_initialize(0, 51612, 200);
	--
	EXECUTE IMMEDIATE 'alter session set current_schema = APPS';
	--
	mo_global.set_policy_context('S', 318);*\

	begin
		fpt_create_payment_ddp_pkg.get_check_id(P_INVOICE_ID          => v_invoice_id,
																						P_BANK_ACCOUNT_ID     => v_bank_account_id,
																						P_CHECK_ID            => v_check_id,
																						P_ACCOUNTING_EVENT_ID => v_accounting_event_id);
	end;

	t_invoice_id(1) := v_invoice_id;

	for c in t_invoice_id.first .. t_invoice_id.last loop
		begin
			fpt_create_payment_ddp_pkg.p_insert_payment_invoice(P_INVOICE_ID          => t_invoice_id(c),
																													P_CHECK_ID            => v_check_id,
																													p_amount              => v_amount,
																													p_bank_account_id     => v_bank_account_id,
																													p_accounting_event_id => v_accounting_event_id);
		end;
	
		dbms_output.put_line(t_invoice_id(c));
	end loop;

	begin
		fpt_create_payment_ddp_pkg.P_submit_payment(p_check_id => v_check_id);
	end;

	x_return_status := 'S';
	x_msg_count     := 1;
	p_check_id      := v_check_id;
  if v_check_id is not null then
    select apc.check_number
    into p_check_number
     from ap_checks_all apc 
    where apc.check_id = v_check_id;
  end if;
exception
	when others then
		x_return_status := 'E';
		x_msg_count     := 1;
		x_msg_data      := sqlerrm;
end;*/ 
 procedure get_vendor(p_invoice_id number,
                      p_vendor_id  out nocopy number,
                      p_vendor_site_id out nocopy number) is
    v_invoice_id number;
    
	begin
		select vendor_id, vendor_site_id
			into p_vendor_id, p_vendor_site_id
			from ap_invoices_all
		 where invoice_id = p_invoice_id
			 and rownum = 1;

	exception
		when others then
			p_vendor_id := null;
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

procedure ap_create_accounting(p_check_id number) is
	l_errbuf  varchar2(100);
	l_retcode varchar2(100);
begin
	AP_DRILLDOWN_PUB_PKG.payment_online_accounting(p_check_id         => p_check_id,
																								 p_accounting_mode  => 'F',
																								 p_errbuf           => l_errbuf,
																								 p_retcode          => l_retcode,
																								 p_calling_sequence => 'ap_create_accounting');
end; 
    
function fc_check_bank_account_name(p_bank_account_name varchar2 ,                                                                                                                                                                                                       p_org_id     number)
	return number is

	v_status          number;
begin

/*	select count(1)
		into v_status
		from ce_bank_accounts       ba,
				 ce_bank_branches_v     cbb,
				 ce_bank_acct_uses_ou_v cbau
	 where 1 = 1
		 and cbau.bank_account_id = ba.bank_account_id
		 and sysdate between trunc(cbb.start_date) and
				 nvl(trunc(cbb.end_date), sysdate + 1)
		 and cbb.branch_party_id = ba.bank_branch_id
		 and sysdate < nvl(ba.end_date, sysdate + 1)
		 and ba.account_classification = 'internal'
		 and cbau.ap_use_enable_flag = 'y'
		 and cbau.org_id = g_org_id
		 and nvl(ba.netting_acct_flag, 'n') <> 'y'
		 and ba.bank_account_name = p_bank_account_name
		 and rownum = 1;*/

  select count(1)
  into v_status
  from ce_bank_accounts       ba,
				 ce_bank_branches_v     cbb,
				 ce_bank_acct_uses_all cbau
	 where 1 = 1
		 and cbau.bank_account_id = ba.bank_account_id
		 and sysdate between trunc(cbb.start_date) and
				 nvl(trunc(cbb.end_date), sysdate + 1)
		 and cbb.branch_party_id = ba.bank_branch_id
		 and sysdate < nvl(ba.end_date, sysdate + 1)
		 and ba.account_classification = 'INTERNAL'
		 and cbau.ap_use_enable_flag = 'Y'
		 and cbau.org_id = p_org_id
		 and nvl(ba.netting_acct_flag, 'N') <> 'Y'
		 and ba.bank_account_name = p_bank_account_name
		 ;
	if nvl(v_status, 0) = 0 then
		return - 1;
	end if;
 return v_status;
exception
	when others then
		return -1;
	
end;  
function fc_get_bank_account_name(p_bank_account_name varchar2 ,                                                                                                                                                                                                       p_org_id     number)
	return number is

	v_bank_account_id          number;
begin
    select t.BANK_ACCOUNT_ID
		into v_bank_account_id
		from CE.CE_BANK_ACCOUNTS t, CE.CE_BANK_ACCT_USES_ALL bu
	 where bu.org_id = p_org_id
		 and t.bank_account_id = bu.bank_account_id
		 and t.bank_account_name = p_bank_account_name
     and rownum = 1;
     
 return v_bank_account_id;
exception
	when others then
		return -1;
	
end;  
PROCEDURE p_insert_payment_invoice(
                           P_INVOICE_ID    IN NUMBER,
                           P_CHECK_ID in NUMBER,
                           p_amount in number,
                           p_accounting_event_id in number,
                           p_bank_account_id in number) IS
  
    cursor cur_invoices is
      select 
             t.invoice_amount invoice_amount_nt,
             decode(t.invoice_currency_code,
                    'VND',
                    t.invoice_amount,
                    t.invoice_amount * t.exchange_rate) invoice_amount,
             t.invoice_id,
             t.invoice_num invoices_num,
             t.invoice_currency_code currency_code,
             t.exchange_rate rate,
             t.exchange_rate_type rate_type,
             to_date(t.exchange_date) rate_date,
             (select vendor_site_code 
             from po_vendor_sites_all 
             where vendor_site_id = t.vendor_site_id) vendor_site_code,           
             t.vendor_id,
             t.vendor_site_id,         
             t.party_id,
             t.party_site_id,
             to_date(t.invoice_date) invoice_date,
             t.invoice_type_lookup_code invoice_type,
             t.set_of_books_id ,
             t.accts_pay_code_combination_id           
        from ap_invoices_all t
       where 1 = 1
         and t.invoice_id = p_invoice_id
   
      ;
   g_org_id          number;
   v_login_id        number;
    x_rowid               varchar2(30) := null;
    v_check_id            number;
    v_invoice_payment_id    number;
    v_check_num           ap_checks.check_number%type;
    v_accounting_event_id number;
    v_payment_document_id number;
    v_payment_num    ap_payment_schedules_all.payment_num%type;
    ----------------------------
    v_vendor_name           ap_suppliers.vendor_name%type;
    v_address_line1         ap_supplier_sites_all.address_line1%type;
    v_payment_profile_id    varchar2(150);
    v_internal_bank_acct_id ce_bank_accounts.bank_account_id%type;
    v_bank_acct_use_id    number;
    -----------------------
    v_bank_account_name ce_bank_accounts.bank_account_name%type;
    v_BANK_ACCOUNT_NUM ce_bank_accounts.bank_account_NUM%type;
    v_legal_enity_id ap_checks_all.legal_entity_id%type;
    v_BANK_ACCOUNT_TYPE ce_bank_accounts.BANK_ACCOUNT_TYPE%type;
    v_BANK_ACCOUNT_NAME_ALT   ce_bank_accounts.BANK_ACCOUNT_NAME_ALT%type;
 begin
  
 apps.mo_global.init('SQLAP');
  --
  apps.fnd_global.apps_initialize(0,51612,200);
  
  EXECUTE IMMEDIATE 'alter session set current_schema = APPS';
  --
  mo_global.set_policy_context('S',318);
  --
  v_login_id := fnd_profile.VALUE('LOGIN_ID');
 -- DBMS_OUTPUT.PUT_LINE('MO Global Org ID Se         t is: '|| fnd_global.org_id);

    v_internal_bank_acct_id := p_bank_account_id;
    v_accounting_event_id := p_accounting_event_id;
    
  select org_id
		into g_org_id
		from ap_invoices_all
	 where invoice_id = p_invoice_id;
   
   
   
   
	select t.bank_account_name,
				 t.BANK_ACCOUNT_NUM,
				 t.ACCOUNT_OWNER_ORG_ID,
				 t.BANK_ACCOUNT_TYPE,
				 t.BANK_ACCOUNT_NAME_ALT,
				 bu.bank_acct_use_id
		into v_bank_account_name,
				 v_BANK_ACCOUNT_NUM,
				 v_legal_enity_id,
				 v_BANK_ACCOUNT_TYPE,
				 v_BANK_ACCOUNT_NAME_ALT,
				 v_bank_acct_use_id
		from CE.CE_BANK_ACCOUNTS t, CE.CE_BANK_ACCT_USES_ALL bu
	 where t.bank_account_id = v_internal_bank_acct_id
		 and t.bank_account_id = bu.bank_account_id;   
    
    for r_invoices in cur_invoices loop
      
       
          v_check_id := p_check_id;
          fnd_file.put_line(fnd_file.log, 'v_check_id: ' || v_check_id);
          --get vendor name
          begin
            select a.vendor_name, b.address_line1
              into v_vendor_name, v_address_line1
              from ap_supplier_sites_all b, ap_suppliers a
             where a.vendor_id = b.vendor_id
               and a.vendor_id = r_invoices.vendor_id
               and b.vendor_site_id = r_invoices.vendor_site_id
               and b.org_id = g_org_id
               and rownum = 1;
          
             dbms_output.put_line(
                              'v_vendor_name: ' || v_vendor_name || '--' ||
                              'v_address_line1' || v_address_line1);
          end;
          --get payment_profile----
          begin
            select t.payment_profile_id
              into v_payment_profile_id
              from iby_payment_profiles t
             where t.system_profile_name = 'FPTR12'
               and rownum = 1;
          end;
        
          begin
            select t.payment_document_id
              into v_payment_document_id
              from ce_payment_documents t
             where t.internal_bank_account_id = v_internal_bank_acct_id
               and rownum = 1;
          end;
        --get v_check_num
				select max(t.check_number) + 1
					into v_check_num
					from ap_checks_all t
				 where t.vendor_id = r_invoices.vendor_id
					 and t.org_id = g_org_id;  
      
      
            select ap_invoice_payments_s.nextval
              into v_invoice_payment_id
              from dual;
      
					 select payment_num
						 into v_payment_num
						 from ap_payment_schedules_all
						where invoice_id = r_invoices.invoice_id;
           
            	begin
		ap_pay_invoice_pkg.ap_pay_invoice(P_invoice_id             => r_invoices.invoice_id,
																			P_check_id               => v_check_id, --:ADJ_INV_PAY.check_id,
																			P_payment_num            => v_payment_num, --:ADJ_INV_PAY.payment_num,
																			P_invoice_payment_id     => v_invoice_payment_id, 
																			P_old_invoice_payment_id => '',
																			P_period_name            => null,
																			P_invoice_type           => r_invoices.invoice_type,
																			P_accounting_date        => trunc(sysdate), 
																			P_amount                 => p_amount,--r_invoices.invoice_amount_nt, 
																			P_Discount_taken         => 0, 
																			P_discount_lost          => '',
																			P_invoice_base_amount    => '',
																			P_payment_base_amount    => '',
																			P_accrual_posted_flag    => 'N',
																			P_cash_posted_flag       => 'N',
																			P_posted_flag            => 'N',
																			P_set_of_books_id        => r_invoices.set_of_books_id, 
																			P_last_updated_by        => 0,
																			 P_last_update_login  => v_login_id,-- :ADJ_INV_PAY.last_updated_by,
                                      P_currency_code  => r_invoices.currency_code ,--:pay_sum_folder.currency_code,
                                   P_base_currency_code  => r_invoices.currency_code,--:parameter.base_currency_code,
                                         P_exchange_rate  => r_invoices.rate,-- :ADJ_INV_PAY.exchange_rate,
                                     P_exchange_rate_type  =>r_invoices.rate_type,-- :ADJ_INV_PAY.exchange_rate_type,
                                         P_exchange_date  =>trunc(sysdate),-- :ADJ_INV_PAY.exchange_date,
                                         P_ce_bank_acct_use_id  => v_internal_bank_acct_id,
                                         P_bank_account_num  =>  v_BANK_ACCOUNT_NUM,
                                        P_bank_account_type  => v_BANK_ACCOUNT_TYPE,
                                       -- P_bank_num    => :pay_sum_folder.bank_num,
                                    /*     P_future_pay_posted_flag=> :ADJ_INV_PAY.future_pay_posted_flag,
                                         P_exclusive_payment_flag=> :ADJ_INV_PAY.exclusive_payment_flag,*/
                                      P_accts_pay_ccid        => r_invoices.accts_pay_code_combination_id,
																			P_gain_ccid => '',
																			P_loss_ccid => '',
																			/* P_future_pay_ccid       => :ADJ_INV_PAY.future_pay_code_combination_id,
                                         P_asset_ccid    => :ADJ_INV_PAY.asset_code_combination_id,*/
																			P_payment_dists_flag => 'N',
																			P_payment_mode       => 'PAY',
																			P_replace_flag       => 'N',
																			/* P_attribute1    => :ADJ_INV_PAY.attribute1,
                                         P_attribute_category  => :ADJ_INV_PAY.attribute_category,
                                         P_global_attribute1  => :ADJ_INV_PAY.global_attribute1,
                                         P_global_attribute2  => :ADJ_INV_PAY.global_attribute2,*/
																			P_calling_sequence    => 'fpt_create_payment_ddp_pkg.p_payment_invoice',
																			P_accounting_Event_id => v_accounting_event_id, 
																			P_org_id              => g_org_id);
                        	end;     
       
  
                    commit;
          end loop;
          -- update check amount
    update ap_checks_all t
    set t.amount = AP_PAY_INVOICE_PKG.ap_pay_update_check_amount(v_check_id)
    where t.check_id = v_check_id;
    
  exception
    when others then
       dbms_output.put_line(
                        'error_stack...' || chr(10) ||
                        dbms_utility.format_error_stack());
        dbms_output.put_line(
                        'error_backtrace...' || chr(10) ||
                        dbms_utility.format_error_backtrace());
    
end;

PROCEDURE P_submit_payment(p_check_id in number) is
l_manual_payment_flag  VARCHAR2(1);
l_payment_function     IBY_EXTERNAL_PAYEES_ALL.payment_function%TYPE;
l_init_msg_list        VARCHAR2(10) := 'F'; 

l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000); 
l_num_printed_docs     NUMBER;    
l_paper_doc_num        IBY_PAYMENTS_ALL.paper_document_number%TYPE;
l_pmt_ref_num          IBY_PAYMENTS_ALL.payment_reference_number%TYPE;
l_return_status        VARCHAR2(10);
l_errorIds             IBY_DISBURSE_SINGLE_PMT_PKG.trxnErrorIdsTab;
l_msg_index_out        NUMBER;
l_payment_id           NUMBER;
l_check_number         NUMBER;
l_error_msg            VARCHAR2(2000);
l_old_check_number     NUMBER;
l_check_id             NUMBER := p_check_id;
l_checkrun_name        ap_checks_all.checkrun_name%type;
l_check_number_api     NUMBER;
l_check_date           DATE;
l_internal_bank_acct_id NUMBER;
l_print_immediate_flag VARCHAR2(1);
l_printer_name         VARCHAR2(255);
l_payment_amount       NUMBER;
l_ext_id number;
v_ap_checks_all ap_checks_all%rowtype;
--bug 6661140
l_event_source_info      xla_events_pub_pkg.t_event_source_info;
l_event_security_context XLA_EVENTS_PUB_PKG.T_SECURITY;
errbuf varchar2(100);
       retcode varchar2(100);
BEGIN
  
  /*apps.mo_global.init('SQLAP');
  --
  apps.fnd_global.apps_initialize(0,20639,200);
  --
 EXECUTE IMMEDIATE 'alter session set current_schema = APPS';
  --
 mo_global.set_policy_context('S',318);*/
   
  select * into v_ap_checks_all 
  from ap_checks 
  where check_id = l_check_id; 
 
   --l_check_number_api := :v_ap_checks_all.check_number;
 -- l_check_date := v_ap_checks_all.check_date;
  select BANK_ACCOUNT_ID
    into l_internal_bank_acct_id
    from CE.CE_BANK_ACCOUNTS t
   where t.bank_account_name = v_ap_checks_all.bank_account_name;   
   
    BEGIN
      SELECT DISTINCT payment_function
        INTO l_payment_function
        FROM IBY_EXTERNAL_PAYEES_ALL
       WHERE payee_party_id = v_ap_checks_all.party_id;
    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        NULL;
    END;
    BEGIN
      SELECT print_instruction_immed_flag, default_printer
        INTO l_print_immediate_flag, l_printer_name
        FROM IBY_PAYMENT_PROFILES
       WHERE payment_profile_id = v_ap_checks_all.payment_profile_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    l_payment_amount := v_ap_checks_all.amount;
  
      select checkrun_name
        into l_checkrun_name
        from ap_checks_all
       where check_id = l_check_id;
       
      if( l_checkrun_name  is null)  then
           update  ap_checks_all
            set   checkrun_name  =   check_id 
           where  check_id = l_check_id ;
      end if;
                                                              

IBY_DISBURSE_SINGLE_PMT_PKG.submit_single_payment(
     p_api_version                =>    1.0,
     p_init_msg_list              =>    'F',
     p_calling_app_id             =>    200,
     p_calling_app_payreq_cd      =>    l_checkrun_name,
     p_is_manual_payment_flag     =>   'Y',-- l_manual_payment_flag,
     p_payment_function           =>    l_payment_function,
     p_internal_bank_account_id   =>    l_internal_bank_acct_id,
     p_pay_process_profile_id     =>    v_ap_checks_all.payment_profile_id, --164
     p_payment_method_cd          =>    v_ap_checks_all.payment_method_code,
     p_legal_entity_id            =>    v_ap_checks_all.legal_entity_id,
     p_organization_id            =>    v_ap_checks_all.org_id,
     p_organization_type          =>    'OPERATING_UNIT',
     p_payment_date               =>    l_check_date,
     p_payment_amount             =>    l_payment_amount,
     p_payment_currency           =>    v_ap_checks_all.currency_code,
     p_payee_party_id             =>    v_ap_checks_all.party_id,
     p_payee_party_site_id        =>    v_ap_checks_all.party_site_id,
     p_supplier_site_id           =>    v_ap_checks_all.vendor_site_id,
     p_payee_bank_account_id      =>    l_internal_bank_acct_id,
     p_override_pmt_complete_pt   =>    'Y', ----AP should always set this parameter to be 'Y'.This ensures that IBY marks the payment complete immediately upon success of the API.
     p_bill_payable_flag          =>    'N',
     p_anticipated_value_date     =>    v_ap_checks_all.anticipated_value_date,
     p_maturity_date              =>    v_ap_checks_all.future_pay_due_date,
     p_payment_document_id        =>    v_ap_checks_all.payment_document_id,
     p_paper_document_number      =>    v_ap_checks_all.check_number,
     p_printer_name               =>    l_printer_name,  --  PPP LOV should return this if PPP has PRoceesing type as "Printed"
     p_print_immediate_flag       =>    'Y',--l_print_immediate_flag,   --  PPP LOV should return this if PPP has PRoceesing type as "Printed"
     p_transmit_immediate_flag    =>    Null,
     p_payee_address_line1        =>    v_ap_checks_all.address_line1,
     p_payee_address_line2        =>    v_ap_checks_all.address_line2,
     p_payee_address_line3        =>    v_ap_checks_all.address_line3,
     p_payee_address_line4        =>    v_ap_checks_all.address_line4,
     p_payee_address_city         =>    v_ap_checks_all.city,
     p_payee_address_county       =>    v_ap_checks_all.county,
     p_payee_address_state        =>    v_ap_checks_all.state,
     p_payee_address_zip          =>    v_ap_checks_all.zip,
     p_payee_address_country      =>    v_ap_checks_all.country,
     p_attribute_category         =>    v_ap_checks_all.attribute_category,
     p_attribute1                 =>    v_ap_checks_all.attribute1,
     p_attribute2                 =>    v_ap_checks_all.attribute2,
     p_attribute3                 =>    v_ap_checks_all.attribute3,
     p_attribute4                 =>    v_ap_checks_all.attribute4,
     p_attribute5                 =>    v_ap_checks_all.attribute5,
     p_attribute6                 =>    v_ap_checks_all.attribute6,
     p_attribute7                 =>    v_ap_checks_all.attribute7,
     p_attribute8                 =>    v_ap_checks_all.attribute8,
     p_attribute9                 =>    v_ap_checks_all.attribute9,
     p_attribute10                =>    v_ap_checks_all.attribute10,
     p_attribute11                =>    v_ap_checks_all.attribute11,
     p_attribute12                =>    v_ap_checks_all.attribute12,
     p_attribute13                =>    v_ap_checks_all.attribute13,
     p_attribute14                =>    v_ap_checks_all.attribute14,
     p_attribute15                =>    v_ap_checks_all.attribute15,
     x_num_printed_docs           =>    l_num_printed_docs,
     x_payment_id                 =>    l_payment_id,
     x_paper_doc_num              =>    l_paper_doc_num,
     x_pmt_ref_num                =>    l_pmt_ref_num,
     x_return_status              =>    l_return_status,
     x_error_ids_tab              =>    l_errorIds,
     x_msg_count                  =>    l_msg_count,
     x_msg_data                   =>    l_msg_data
     );
     
  /*   dbms_output.put_line(v_ap_checks_all.check_number);
       dbms_output.put_line(l_payment_id);
         dbms_output.put_line(l_paper_doc_num);
           dbms_output.put_line(l_pmt_ref_num);
             dbms_output.put_line(l_return_status);
               dbms_output.put_line( l_checkrun_name);*/
     
    IF (l_return_status = 'S') THEN

      UPDATE AP_CHECKS_ALL
      SET    payment_id  = l_payment_id
      WHERE check_id = v_ap_checks_all.check_id;
      v_ap_checks_all.payment_id := l_payment_id;
   END IF;
 commit;
 
    begin
      
       AP_CHECKS_PKG.Subscribe_To_Payment_Event(
               P_Event_Type       => 'PAYMENT_CREATED',
               P_Check_ID         => l_check_id,--:PAY_SUM_FOLDER.check_id,
               P_Application_ID   => 200,
               P_Return_Status    => l_return_status,
               P_Msg_Count        => l_msg_count,
               P_Msg_Data         => l_msg_data,
               P_Calling_Sequence => 'ADJ_INV_PAY_INSERT.POST_INSERT');
      end;
    dbms_output.put_line(l_return_status);
               dbms_output.put_line( l_msg_data);
    
  /*   -- create accounting final post, ky GL phai open
    declare
      l_errbuf  varchar2(100);
      l_retcode varchar2(100);
    begin
    AP_DRILLDOWN_PUB_PKG.payment_online_accounting(
             p_check_id         => l_check_id,
             p_accounting_mode  => 'P',
             p_errbuf           => l_errbuf,
             p_retcode          => l_retcode,
             p_calling_sequence => 'PAY_SUM_FOLDER_EVENT_RECORD.SPECIAL2');      
     end;*/
                                           
 
end;


-- Author  : hungdd
-- Created : 3/18/2022 5:00:59 PM
-- Purpose : p_create_check_id
procedure p_create_check(p_ddp_pay_baolanh in DDP_pay_baolanh_Rec_Type,
												 x_return_status   out nocopy varchar2,
												 x_msg_count       out nocopy number,
												 x_msg_data        out nocopy varchar2,
												 p_check_id        out nocopy number,
                         p_check_num        out nocopy ap_checks.check_number%type   ) is

	v_org_id              number := p_ddp_pay_baolanh.org_id;
	v_login_id            number;
	x_rowid               varchar2(30) := null;
	v_check_id            number;
	v_invoice_payment_id  number;
	v_check_num           ap_checks.check_number%type;
	v_accounting_event_id number;
	v_payment_document_id number;
	v_payment_num        number;
	----------------------------
	v_vendor_name           ap_suppliers.vendor_name%type;
	v_vendor_side_code      ap_supplier_sites_all.vendor_site_code%type;
	v_address_line1         ap_supplier_sites_all.address_line1%type;
	v_party_id              number;
	v_party_site_id         number;
	v_payment_profile_id    varchar2(150);
	v_internal_bank_acct_id ce_bank_accounts.bank_account_id%type;
	v_bank_acct_use_id      number;
	-----------------------
	v_bank_account_name     ce_bank_accounts.bank_account_name%type;
	v_BANK_ACCOUNT_NUM      ce_bank_accounts.bank_account_NUM%type;
	v_legal_enity_id        ap_checks_all.legal_entity_id%type;
	v_BANK_ACCOUNT_TYPE     ce_bank_accounts.BANK_ACCOUNT_TYPE%type;
	v_BANK_ACCOUNT_NAME_ALT ce_bank_accounts.BANK_ACCOUNT_NAME_ALT%type;
  v_vendor_id  number;
  v_vendor_site_id number;
  v_date date;
   v_RATE_TYPE ap_checks.exchange_rate_type%type;
    v_rate_date ap_checks.exchange_date%type;
    v_currency ap_checks.currency_code%type;
    v_set_of_books_id number;
    v_code_combination_id number;
    v_invoice_type   ap_invoices_all.invoice_type_lookup_code%type;
begin
  
   x_return_status := 'S';
  -- get info from invoice_id
	select t.vendor_id,
				 t.vendor_site_id,
				 t.invoice_currency_code,
				 t.set_of_books_id,
				 t.accts_pay_code_combination_id,
         t.invoice_type_lookup_code 
	
		into v_vendor_id,
				 v_vendor_site_id,
				 v_currency,
				 v_set_of_books_id,
				 v_code_combination_id,
         v_invoice_type
		from ap_invoices_all t
	 where t.invoice_id = p_ddp_pay_baolanh.INVOICE_ID;  
   
    v_date := to_date(p_ddp_pay_baolanh.Pay_date,'DD/MM/RRRR');
   	--- get bank info
    
	 begin
   select t.bank_account_name,
				 t.BANK_ACCOUNT_NUM,
				 t.ACCOUNT_OWNER_ORG_ID,
				 t.BANK_ACCOUNT_TYPE,
				 t.BANK_ACCOUNT_NAME_ALT,
				 bu.bank_acct_use_id
		into v_bank_account_name,
				 v_BANK_ACCOUNT_NUM,
				 v_legal_enity_id,
				 v_BANK_ACCOUNT_TYPE,
				 v_BANK_ACCOUNT_NAME_ALT,
				 v_bank_acct_use_id
		from CE.CE_BANK_ACCOUNTS t, CE.CE_BANK_ACCT_USES_ALL bu
	 where bu.org_id = v_org_id
		 and t.bank_account_id = bu.bank_account_id
		 and t.bank_account_name = p_ddp_pay_baolanh.Bank_account_name
     and rownum = 1;
     exception when others then
       x_msg_data := 'no data bank name';
  end;
	v_internal_bank_acct_id := v_bank_acct_use_id;
	-- get chek_id
	select ap_checks_s.nextval into v_check_id from dual;
	-- get check_num
	declare
		l_return_status varchar2(1);
		l_msg_count     number;
		l_msg_data      varchar2(200);
	begin
		iby_disburse_ui_api_pub_pkg.validate_paper_doc_number(p_api_version       => 1.0,
																													p_init_msg_list     => fnd_api.g_false,
																													p_payment_doc_id    => v_payment_document_id,
																													x_paper_doc_num     => v_check_num,
																													x_return_status     => l_return_status,
																													x_msg_count         => l_msg_count,
																													x_msg_data          => l_msg_data,
																													show_warn_msgs_flag => 't');
	end;
	if v_check_num is null then
		v_check_num := v_check_id;
	end if;

	--get vendor info 
	begin
		select a.vendor_name,
					 b.vendor_site_code,
					 b.address_line1,
					 a.party_id,
					 b.party_site_id
			into v_vendor_name,
					 v_vendor_side_code,
					 v_address_line1,
					 v_party_id,
					 v_party_site_id
			from ap_supplier_sites_all b, ap_suppliers a
		 where a.vendor_id = b.vendor_id
			 and a.vendor_id = v_vendor_id
			 and b.vendor_site_id = v_vendor_site_id
			 and b.org_id = v_org_id
			 and rownum = 1;
	
	exception
		when no_data_found then
			v_vendor_name   := null;
			v_address_line1 := null;
      x_msg_data := 'vendor id not correct';
	end;

	--get payment_profile id----
	begin
		select t.payment_profile_id
			into v_payment_profile_id
			from iby_payment_profiles t
		 where t.system_profile_name = 'FPTR12'
			 and rownum = 1;
	end;
	-- get payment_document_id
	begin
		select t.payment_document_id
			into v_payment_document_id
			from ce_payment_documents t
		 where t.internal_bank_account_id = v_internal_bank_acct_id
			 and rownum = 1;
       exception when others then
       x_msg_data := 'v_internal_bank_acct_id not correct';  
	end;
  -- get payment_num
	begin
		select payment_num
			into v_payment_num	
			from ap_payment_schedules_all
		 where invoice_id = p_ddp_pay_baolanh.invoice_id
     and rownum=1;
	exception
		when others then
			v_payment_num := 1;
      x_msg_data := 'v_payment_num not correct'; 
	end;  
  
    v_RATE_TYPE := 'User';
    v_rate_date := to_date(p_ddp_pay_baolanh.Pay_date,'DD/MM/YYYY');
	-- insert ap_check
	begin
		ap_checks_pkg.insert_row(x_rowid               => x_rowid,
														 x_amount              => p_ddp_pay_baolanh.PAY_AMOUNT,
														 x_ce_bank_acct_use_id => v_bank_acct_use_id,
														 x_bank_account_name   => v_bank_account_name,
														 x_check_date          => v_date,
														 x_check_id            => v_check_id,
														 x_check_number        => v_check_num,
														 x_currency_code       => v_currency,
														 x_last_updated_by     => 0,
														 x_last_update_date    => sysdate,
														 x_payment_type_flag => 'Q',
														 x_address_line1            => v_address_line1, --:pay_sum_folder.address_line1,
														 x_checkrun_name            => null, --:pay_sum_folder.checkrun_name,
														 x_check_format_id          => null, --:pay_sum_folder.check_format_id,
														 x_check_stock_id           => null, --:pay_sum_folder.check_stock_id,
														 x_city                     => null, --:pay_sum_folder.city,
														 x_country                  => 'VN', --:pay_sum_folder.country,
														 x_created_by               => 0, --:pay_sum_folder.created_by,
														 x_creation_date            => sysdate, --:pay_sum_folder.creation_date,
														 x_last_update_login        => v_login_id, --:pay_sum_folder.last_update_login,
														 x_status_lookup_code       => 'NEGOTIABLE', --:pay_sum_folder.status_lookup_code,
														 x_vendor_name              => v_vendor_name, --:pay_sum_folder.vendor_name,
														 x_vendor_site_code         => v_vendor_side_code, --:pay_sum_folder.vendor_site_code,
														 x_external_bank_account_id => v_internal_bank_acct_id, --:pay_sum_folder.external_bank_account_id,
														 x_zip                      => null, --:pay_sum_folder.zip,
														 x_bank_account_num         => v_BANK_ACCOUNT_NUM, --:pay_sum_folder.bank_account_num,
														 x_bank_account_type        => null, --:pay_sum_folder.bank_account_type,
														 x_bank_num                 => null, --:pay_sum_folder.bank_num,
														 x_check_voucher_num        => null, --:pay_sum_folder.check_voucher_num,
														 x_cleared_amount           => null, --:pay_sum_folder.cleared_amount,
														 x_cleared_date             => null, --:pay_sum_folder.cleared_date,
														 x_doc_category_code        => null, --:pay_sum_folder.doc_category_code,
														 x_doc_sequence_id          => null, --:pay_sum_folder.doc_sequence_id,
														 x_doc_sequence_value       => null, --:pay_sum_folder.doc_sequence_value,
														 x_province                 => null, --:pay_sum_folder.province,
														 x_released_date            => null, --:pay_sum_folder.released_date,
														 x_released_by              => null, --:pay_sum_folder.released_by,
														 x_state                    => null, --:pay_sum_folder.state,
														 x_stopped_date             => null, --:pay_sum_folder.stopped_date,
														 x_stopped_by               => null, --:pay_sum_folder.stopped_by,
														 x_void_date                => null, --:pay_sum_folder.void_date,
														 x_attribute1               => null, --:pay_sum_folder.attribute1,
														 x_attribute2               => null, --:pay_sum_folder.attribute2,
														 x_attribute3               => p_ddp_pay_baolanh.PAY_SOPHIEU, --:pay_sum_folder.attribute3,
														 x_attribute4               => p_ddp_pay_baolanh.LYDO, --:pay_sum_folder.attribute4,
														 x_attribute5               => null, --:pay_sum_folder.attribute5,
														 x_attribute6               => null, --:pay_sum_folder.attribute6,
														 x_attribute7               => null, --:pay_sum_folder.attribute7,
														 x_attribute8               => null, --:pay_sum_folder.attribute8,
														 x_attribute9               => null, --:pay_sum_folder.attribute9,
														 x_attribute_category       => 'Payment Informations', --:pay_sum_folder.attribute_category,
														 x_future_pay_due_date      => null, --:pay_sum_folder.future_pay_due_date,
														 x_treasury_pay_date        => null, --:pay_sum_folder.treasury_pay_date,
														 x_treasury_pay_number      => null, --:pay_sum_folder.treasury_pay_number,
														 x_withholding_status_lkup_code => null, --:pay_sum_folder.withholding_status_lookup_code,
														 x_reconciliation_batch_id      => null, --:pay_sum_folder.reconciliation_batch_id,
														 x_cleared_base_amount          => null, --:pay_sum_folder.cleared_base_amount,
														 x_cleared_exchange_rate        => null, --:pay_sum_folder.cleared_exchange_rate,
														 x_cleared_exchange_date        => null, --:pay_sum_folder.cleared_exchange_date,
														 x_cleared_exchange_rate_type   => null, --:pay_sum_folder.cleared_exchange_rate_type,
														 x_address_line4                => null, --:pay_sum_folder.address_line4,
														 x_county                       => null, --:pay_sum_folder.county,
														 x_address_style                => null, --:pay_sum_folder.address_style,
														 x_org_id                       => v_org_id, --:pay_sum_folder.org_id,
														 x_vendor_id                    => v_vendor_id, --:pay_sum_folder.vendor_id,
														 x_vendor_site_id               => v_vendor_site_id, --:pay_sum_folder.vendor_site_id,
														 x_exchange_rate                => p_ddp_pay_baolanh.PAY_RATE, --:pay_sum_folder.exchange_rate,
														 x_exchange_date                => v_rate_date, --:pay_sum_folder.exchange_date,
														 x_exchange_rate_type           => v_RATE_TYPE, --:pay_sum_folder.exchange_rate_type,
														 x_base_amount                  => null, --:pay_sum_folder.base_amount,
														 x_checkrun_id                  => null, --:pay_sum_folder.checkrun_id,
														 x_calling_sequence             => 'p_create_check', --'apxpawkb',
														 x_transfer_priority            => null, --:pay_sum_folder.transfer_priority,
														 x_description                  => p_ddp_pay_baolanh.PAY_DESCRIPTION, --:pay_sum_folder.description,
														 x_anticipated_value_date       => null, --:pay_sum_folder.anticipated_value_date,
														 x_actual_value_date            => null, --:pay_sum_folder.actual_value_date,
														 --iby:sp
														 x_payment_method_code          => 'CHECK', --:pay_sum_folder.payment_method_code,
														 x_payment_profile_id           => v_payment_profile_id, --:pay_sum_folder.payment_profile_id,
														 x_bank_charge_bearer           => 'I', --:pay_sum_folder.bank_charge_bearer,
														 x_settlement_priority          => null, --:pay_sum_folder.settlement_priority,
														 x_payment_document_id          => v_payment_document_id, --:pay_sum_folder.payment_document_id,
														 x_party_id                     => v_party_id, --:pay_sum_folder.party_id,
														 x_party_site_id                => v_party_site_id, --:pay_sum_folder.party_site_id,
														 x_legal_entity_id              => v_legal_enity_id 
														
														 );
	
		commit;
	end;
	-- insert payment history
	begin
		ap_reconciliation_pkg.insert_payment_history(x_check_id                    => v_check_id,
																								 x_transaction_type            => 'PAYMENT CREATED',
																								 x_accounting_date             => v_date,
																								 x_trx_bank_amount             => null,
																								 x_errors_bank_amount          => null,
																								 x_charges_bank_amount         => null,
																								 x_bank_currency_code          => null,
																								 x_bank_to_base_xrate_type     => null,
																								 x_bank_to_base_xrate_date     => null,
																								 x_bank_to_base_xrate          => null,
																								 x_trx_pmt_amount              => p_ddp_pay_baolanh.PAY_AMOUNT,
																								 x_errors_pmt_amount           => null,
																								 x_charges_pmt_amount          => null,
																								 x_pmt_currency_code           => v_currency,
																								 x_pmt_to_base_xrate_type      => null,
																								 x_pmt_to_base_xrate_date      => null,
																								 x_pmt_to_base_xrate           => null,
																								 x_trx_base_amount             => null,
																								 x_errors_base_amount          => null,
																								 x_charges_base_amount         => null,
																								 x_matched_flag                => null,
																								 x_rev_pmt_hist_id             => null,
																								 x_creation_date               => sysdate,
																								 x_created_by                  => 0,
																								 x_last_update_date            => sysdate,
																								 x_last_updated_by             => 0,
																								 x_last_update_login           => v_login_id,
																								 x_program_update_date         => null,
																								 x_program_application_id      => null,
																								 x_program_id                  => null,
																								 x_request_id                  => null,
																								 x_calling_sequence            => 'p_create_check',
																								 x_accounting_event_id         => v_accounting_event_id,
																								 x_org_id                      => v_org_id,
																								 x_invoice_adjustment_event_id => null);
		commit;
	end;
	-- get accounting_event_id
	begin
		select accounting_event_id
			into v_accounting_event_id
			from ap_payment_history_all
		 where check_id = v_check_id
			 and transaction_type = 'PAYMENT CREATED'
       and rownum=1;
	exception
		when others then
			x_msg_data :=	'error in select accounting_event_id: ' || sqlerrm;
	end;
  -- insert invoice payment
 /* begin
   p_insert_payment_invoice(
                           P_INVOICE_ID    => p_ddp_pay_baolanh.invoice_id,
                           P_CHECK_ID => v_check_id,
                           p_amount => p_ddp_pay_baolanh.PAY_AMOUNT,
                           p_accounting_event_id => v_accounting_event_id,
                           p_bank_account_id => v_internal_bank_acct_id);
     
     end;    */                  
  select ap_invoice_payments_s.nextval into v_invoice_payment_id from dual;
  -- insert invoice payment
	Begin  
		ap_pay_invoice_pkg.ap_pay_invoice(P_invoice_id             => p_ddp_pay_baolanh.invoice_id,
																			P_check_id               => v_check_id, --:ADJ_INV_PAY.check_id,
																			P_payment_num            => v_payment_num, --:ADJ_INV_PAY.payment_num,
																			P_invoice_payment_id     => v_invoice_payment_id,
																			P_old_invoice_payment_id => '',
																			P_period_name            => null,
																			P_invoice_type           => v_invoice_type,
																			P_accounting_date        => v_date,
																			P_amount                 => p_ddp_pay_baolanh.PAY_AMOUNT,
																			P_Discount_taken         => 0,
																			P_discount_lost          => '',
																			P_invoice_base_amount    => '',
																			P_payment_base_amount    => '',
																			P_accrual_posted_flag    => 'N',
																			P_cash_posted_flag       => 'N',
																			P_posted_flag            => 'N',
																			P_set_of_books_id        => v_set_of_books_id,
																			P_last_updated_by        => 0,
																			P_last_update_login      => v_login_id, -- :ADJ_INV_PAY.last_updated_by,
																			P_currency_code          => v_currency, 
																			P_base_currency_code     => v_currency,
																			P_exchange_rate          => p_ddp_pay_baolanh.PAY_RATE,
																			P_exchange_rate_type     => v_RATE_TYPE, 
																			P_exchange_date          => v_rate_date,
																			P_ce_bank_acct_use_id    => v_internal_bank_acct_id,
																			P_bank_account_num       => v_BANK_ACCOUNT_NUM,
																			P_bank_account_type      => v_BANK_ACCOUNT_TYPE,																	
																			P_accts_pay_ccid => v_code_combination_id,
																			P_gain_ccid      => '',
																			P_loss_ccid      => '',																		
																			P_payment_dists_flag => 'N',
																			P_payment_mode       => 'PAY',
																			P_replace_flag       => 'N',																		
																			P_calling_sequence    => 'p_create_check',
																			P_accounting_Event_id => v_accounting_event_id,
																			P_org_id              => v_org_id);
	
	
    
    commit;
	end; 
  
  
  -- submit check	
  begin
		P_submit_payment(v_check_id);
	end;
	
  p_check_id := v_check_id;
  p_check_num := v_check_num;
    x_return_status := 'S';
		x_msg_count     := 1;
		x_msg_data      := 'create success';
exception
	when others then
		x_return_status := 'E';
		x_msg_count     := 1;
		x_msg_data      := sqlerrm;
	
end;
    


PROCEDURE create_ddp_pay_baolanh_all(p_ddp_id                  in varchar2,
																		 p_ddp_pay_baolanh_tbl     in ddp_pay_baolanh_tbl_type,
																		 x_return_status           out nocopy varchar2,
																		 x_msg_count               out nocopy number,
																		 x_msg_data                out nocopy varchar2,
																		 x_ddp_request_code        out nocopy varchar2,
																		 x_DDP_pay_baolanh_Tbl_out OUT NOCOPY ddp_pay_baolanh_tbl_type_out) is

	v_index               number := p_ddp_pay_baolanh_tbl.first;
	v_DDP_pay_baolanh_Tbl ddp_pay_baolanh_tbl_type := p_ddp_pay_baolanh_tbl;
	v_request_id          number;
	default_ccid          number;
	v_count               number;
	verr                  varchar2(200);
	v_start_date          date;
	v_retcode             varchar2(100);
	v_error_buf           varchar2(100);
	vCheck_id             number;
	vInvoice_batch_ID     number;
	vInvoice_number       varchar2(100);
	vInvoice_id           number;
begin
	-->save point 
	-->SAVEPOINT create_ddp_baolanh_all;
	v_start_date    := sysdate;
	x_return_status := fnd_api.g_ret_sts_success;
	g_group_id      := p_DDP_ID;
	--> check ddp_id in process
	begin
		select count(1)
			into v_count
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'pay_baolanh'
			 and status = 'P';
	exception
		when others then
			v_count := null;
	end;
	if nvl(v_count, 0) > 0 then
		x_return_status := 'PE';
		x_msg_count     := 1;
		x_msg_data      := 'The request with DDP_ID ' || p_ddp_id ||
											 ' is in processing!!!';
		return;
	end if;
	--> check ddp_id da chay roi
	begin
		select count(1)
			into v_count
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'pay_baolanh'
			 and status = 'S';
	exception
		when others then
			v_count := null;
	end;
	if nvl(v_count, 0) > 0 then
		-- tra du lieu khi goi lai ddp_id da chay thanh cong 
		for i in 1 .. p_ddp_pay_baolanh_tbl.COUNT LOOP
			begin
				select
				
				 x.x_check_id, x.x_check_number, ddp_request_code
				
					into x_DDP_pay_baolanh_Tbl_out(i).x_check_id,
							 x_DDP_pay_baolanh_Tbl_out(i).x_check_number,
							 x_DDP_pay_baolanh_Tbl_out(i).ddp_request_code
					from FPT_DDP_baolanh x
				 where ddp_id = p_ddp_id
					 and stt = i;
			exception
				when others then
					null;
			end;
		end loop;
	
		x_return_status := 'S';
		x_msg_count     := 1;
		x_msg_data      := 'Payment Success!!!';
		return;
	end if;

	--> insert ddp_id
	insert into fpt_ddp_process
		(ddp_id, program, status, start_time)
	values
		(p_ddp_id, 'pay_baolanh', 'P', sysdate);
  commit;
	-- check data input
	WHILE v_index <= p_ddp_pay_baolanh_tbl.LAST LOOP
	
		--> check invoice_id
		if ck_invoice_id(p_invoice_id => v_DDP_pay_baolanh_Tbl(v_index)
																		 .invoice_id,
										 p_org_id     => v_DDP_pay_baolanh_Tbl(v_index).org_id) =
			 false then
			x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := 'invoice_id or org_id not correct';
			x_ddp_request_code := v_DDP_pay_baolanh_Tbl(v_index).ddp_request_code;
			goto STOP;
		end if;
	
		-- check mo ky GL
		if check_period(v_DDP_pay_baolanh_Tbl(v_index).org_id,
										to_date(v_DDP_pay_baolanh_Tbl(v_index).Pay_date,
														'DD/MM/YYYY')) = -1 then
			x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := 'GL period dose not open';
			x_ddp_request_code := v_DDP_pay_baolanh_Tbl(v_index).ddp_request_code;
			goto STOP;
		end if;
	
		-- check bank_account id
		if v_DDP_pay_baolanh_Tbl(v_index)
		 .Bank_account_name is not null and
				fc_check_bank_account_name(p_bank_account_name => v_DDP_pay_baolanh_Tbl(v_index)
																											.Bank_account_name,
																 p_org_id          => v_DDP_pay_baolanh_Tbl(v_index)
																											.org_id) = -1 then
			x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := 'Bank_account_name not exsits';
			x_ddp_request_code := v_DDP_pay_baolanh_Tbl(v_index).ddp_request_code;
			goto STOP;
		end if;
		--> check INVOICE_ID amount remain
		if v_DDP_pay_baolanh_Tbl(v_index)
		 .PAY_AMOUNT is not null and
				check_pay_amount(p_invoice_id => v_DDP_pay_baolanh_Tbl(v_index)
																				 .invoice_id,
												 p_amount     => v_DDP_pay_baolanh_Tbl(v_index)
																				 .PAY_AMOUNT) = -1 then
			x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := 'PAY_AMOUNT is larger than amount remain!!!';
			x_ddp_request_code := v_DDP_pay_baolanh_Tbl(v_index).ddp_request_code;
			goto STOP;
		end if;
	
		<<STOP>>
		v_index := v_index + 1;
		exit when x_return_status = 'E';
	end loop;

	if x_return_status = 'E' then
		Delete fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'pay_baolanh'
			 ;
		commit;
		rollback;
		return;
	end if;

	--> Sinh Invoice
	v_index := p_ddp_pay_baolanh_tbl.FIRST;

	WHILE v_index <= p_ddp_pay_baolanh_tbl.LAST LOOP
	
		-->Create payment
      declare
          v_org_id number :=   p_ddp_pay_baolanh_tbl(v_index).ORG_ID;
          v_resp_id number;
          v_segment1 varchar2(10);
    begin
          /* apps.mo_global.init('SQLAP');
       apps.fnd_global.apps_initialize(0,20639,200);
       EXECUTE IMMEDIATE 'alter session set current_schema = APPS';
          mo_global.set_policy_context('S',v_org_id);*/
           v_segment1 := get_segment1(v_org_id);
											SELECT responsibility_id
												into v_resp_id
												FROM fnd_responsibility_tl
											 WHERE responsibility_name like
														 'Payables Manager-%'
												 and responsibility_id in
														 (select x.responsibility_id
																from fnd_responsibility x
															 where x.web_host_name = v_segment1
																 and x.application_id = 200
                                 and x.end_date is null)
                                 and rownum = 1;  
             mo_global.init('SQLAP');
	    	  mo_global.set_policy_context('S', v_org_id);
           EXECUTE IMMEDIATE 'alter session set current_schema = APPS';
          fnd_global.apps_initialize(user_id      => 0,
															 resp_id      => v_resp_id,
															 resp_appl_id => 200);
	/*	v_bank_id := fc_get_bank_account_name(p_ddp_pay_baolanh_tbl(v_index).Bank_account_name,p_ddp_pay_baolanh_tbl(v_index).org_id);*/
			
		  p_create_check(p_ddp_pay_baolanh => p_ddp_pay_baolanh_tbl(v_index),
												 x_return_status   => x_return_status,
										    x_msg_count       => x_msg_count,
										     x_msg_data        => x_msg_data,
												 p_check_id       => x_DDP_pay_baolanh_Tbl_out(v_index).X_check_id,
                         p_check_num        => x_DDP_pay_baolanh_Tbl_out(v_index).x_check_number );
                         
      /*ap_payment_create(p_invocie_id => p_ddp_pay_baolanh_tbl(v_index).invoice_id,
                            p_bank_account_id  => v_bank_id,
                            p_amount   => p_ddp_pay_baolanh_tbl(v_index).PAY_AMOUNT,
                            p_check_id   => x_DDP_pay_baolanh_Tbl_out(v_index).X_check_id,
                            p_check_number => x_DDP_pay_baolanh_Tbl_out(v_index).x_check_number,
                            x_return_status   => x_return_status,
										    x_msg_count       => x_msg_count,
										     x_msg_data        => x_msg_data);*/
         x_DDP_pay_baolanh_Tbl_out(v_index).ddp_request_code :=    p_ddp_pay_baolanh_tbl(v_index).ddp_request_code; 
    end;
	
		v_index := v_index + 1;
		exit when x_return_status = 'E';
	end loop;

	-->Neu thanh cong se dinh khoan final va out put 
	if x_return_status = 'S' then
		for i in 1 .. x_DDP_pay_baolanh_Tbl_out.count loop
			begin
				-->Dinh khoan
			     mo_global.init('SQLAP');
	    	  --mo_global.set_policy_context('S', v_org_id);
          fnd_global.apps_initialize(user_id      => 0,
															 resp_id      => 20639,
															 resp_appl_id => 200);
          begin        
			    ap_create_accounting(x_DDP_pay_baolanh_Tbl_out(i).x_check_id);
          end;
				-->Output
				insert into FPT_DDP_baolanh
					(ddp_id, STT, x_check_number, x_check_id, ddp_request_code)
				values
					(p_ddp_id,
					 i,
					 x_DDP_pay_baolanh_Tbl_out(i).x_check_number,
					 x_DDP_pay_baolanh_Tbl_out(i).x_check_id,
					 x_DDP_pay_baolanh_Tbl_out(i).ddp_request_code);
				commit;
			end;
		end loop;
	else
    rollback;
		-->Xoa du lieu
		for i in 1 .. x_DDP_pay_baolanh_Tbl_out.count loop
			begin
				x_DDP_pay_baolanh_Tbl_out.delete(i);
			end;
		end loop;
	 delete fpt_ddp_process s
	 where s.program = 'pay_baolanh'
		 and s.ddp_id = p_ddp_id;	
     commit;	
     return;
	end if;

	--> update trang thai ddp_id
	update fpt_ddp_process
		 set Status = 'S', end_time = sysdate
	 where ddp_id = p_ddp_id
		 and program = 'pay_baolanh';
	commit;
	x_return_status := 'S';
	x_msg_count     := 1;
	x_msg_data      := 'Payment Success!!!';

exception
	when others then
		x_return_status := 'E';
		x_msg_count     := 1;
		x_msg_data      := sqlerrm;
		rollback;
    return;
end;END FPT_DDP_PAY_BL_PUB_V1 ;
/
