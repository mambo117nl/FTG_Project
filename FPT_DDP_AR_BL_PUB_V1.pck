CREATE OR REPLACE PACKAGE FPT_DDP_AR_BL_PUB_V1 AS
/* $Header: FPT_DDP_AR_BL_PUB_V1.pls 120.3 2005/07/19 18:56:53 repuri ship$ */
/*#
 * baolanh  API
 * This API contains the procedures to insert and update Salesrep record.
 * @rep:scope public
 * @rep:product AR
 * @rep:displayname DDP AR baolanh API
 * @rep:category BUSINESS_ENTITY AR_MEMO_baolanh

*/
  /*****************************************************************************************
   This is a public API that caller will invoke. 
   It provides procedures for ing baolanh, like
   fpt_ap_inv_ from other modules.
   Its main procedures are as following:
   FPT_DDP_AR_BL
   ******************************************************************************************/


 TYPE DDP_BAOLANH_TYPE IS RECORD (

      DDP_REQUEST_CODE  VARCHAR2(50),
      ORG_ID  NUMBER,
      TRNX_TYPE_NAME          VARCHAR2(50),  
      TRX_DATE  VARCHAR2(100),
      GL_DATE  VARCHAR2(100),           
      CURRENCY  VARCHAR2(100), 
      EXCHANGE_DATE VARCHAR2(100), 
      EXCHANGE_RATE NUMBER,
      CUSTOMER_ID  NUMBER,
      BILL_TO_ID  NUMBER,
      SO_HOADON VARCHAR2(100), -- ATT3
      DIENGIAI       VARCHAR2(100), -- ATT6
      PROJECT_ID Number, -- ATT10
   ---- LINE
      LINE_DESCRIPTION RA_CUSTOMER_TRX_LINES_ALL.DESCRIPTION%TYPE,
      UNIT_SELLING_PRICE  RA_CUSTOMER_TRX_LINES_ALL.UNIT_SELLING_PRICE%TYPE,
      --AMOUNT     NUMBER,
      DISTRIBUTE_ACCOUNT  VARCHAR2(100) 
    
  );
  
  
TYPE DDP_baolanh_Tbl IS TABLE OF DDP_baolanh_Type INDEX BY BINARY_INTEGER;

TYPE DDP_baolanh_Type_out IS RECORD (

      DDP_REQUEST_CODE  VARCHAR2(50),
      p_Tranx_id    number,
      p_tranx_number    ra_customer_trx.trx_number%type
    
  );
  
  
TYPE DDP_baolanh_Tbl_out IS TABLE OF DDP_baolanh_Type_out INDEX BY BINARY_INTEGER;

/* Procedure to  baolanh to invoice and receipt 
  based on input values passed by calling routines. */
/*#
 *  baolanh invocie and receipt API   
 * This procedure allows the user to create a baolanh record.
 * @param p_DDP_ID batch ID.
 * @param p_DDP_baolanh_Tbl  baolanh record.
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
 * @param p_DDP_baolanh_Tbl_out p_DDP_baolanh_Tbl_out
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  DDP AR baolanh API
 */ 
 

PROCEDURE  FPT_DDP_AR_BL
  (   p_DDP_ID                     IN   VARCHAR2,
      p_DDP_baolanh_Tbl                  IN  DDP_baolanh_Tbl,    
      x_return_status                  OUT NOCOPY    VARCHAR2,
      x_msg_count                      OUT NOCOPY    NUMBER,
      x_msg_data                       OUT NOCOPY    VARCHAR2,
      x_ddp_request_code               OUT NOCOPY VARCHAR2,
      p_DDP_baolanh_Tbl_out           OUT NOCOPY  DDP_baolanh_Tbl_out
  );

 


end FPT_DDP_AR_BL_PUB_V1;
/
CREATE OR REPLACE PACKAGE BODY FPT_DDP_AR_BL_PUB_V1 AS
/* $Header: FPT_DDP_AR_BL_PUB_V1.pls 120.3 2005/07/19 18:56:53 repuri ship$ */
-- Author  : hungdd
-- Created : 3/3/2022 3:19:01 PM
-- Purpose : 


PROCEDURE set_org_context_in_api(p_org_id         IN OUT NOCOPY NUMBER,
                                  p_return_status  OUT    NOCOPY VARCHAR2)
 AS
 l_curr_org_id                  number;
 l_status                       VARCHAR2(1);
 l_default_org_id               number;
 BEGIN
     p_return_status := FND_API.G_RET_STS_SUCCESS;

     l_default_org_id := MO_UTILS.Get_Default_Org_ID;
     l_curr_org_id := mo_global.get_current_org_id;

     IF (p_org_id is null or
            p_org_id = FND_API.G_MISS_NUM) THEN
            If l_curr_org_id is not null then
              p_org_id := l_curr_org_id;
            else
              p_org_id := l_default_org_id;
            end if;
     END IF;

     l_status := MO_GLOBAL.check_valid_org(p_org_id);

     IF l_Status = 'N' THEN
           p_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
        mo_global.set_policy_context('S',p_org_id);
           /*-------------------------------------------------+
            | Initialize SOB/org dependent variables          |
            +-------------------------------------------------*/
        arp_global.init_global(p_org_id);
        arp_standard.init_standard(p_org_id);
     END IF;

 EXCEPTION
   WHEN others THEN Raise;

 END set_org_context_in_api;
   
FUNCTION set_context(i_user_name IN VARCHAR2,
										 i_resp_name IN VARCHAR2,
										 i_org_id    IN NUMBER) RETURN VARCHAR2 IS
	v_user_id      NUMBER;
	v_resp_id      NUMBER;
	v_resp_appl_id NUMBER;
	v_lang         VARCHAR2(100);
	v_session_lang VARCHAR2(100) := fnd_global.current_language;
	v_return       VARCHAR2(10) := 'T';
	v_nls_lang     VARCHAR2(100);
	v_org_id       NUMBER := i_org_id;
	/* Cursor to get the user id information based on the input user name */
	CURSOR cur_user IS
		SELECT user_id FROM fnd_user WHERE user_name = i_user_name;
	/* Cursor to get the responsibility information */
	CURSOR cur_resp IS
		SELECT responsibility_id, application_id, language
			FROM fnd_responsibility_tl
		 WHERE responsibility_name = i_resp_name;
	/* Cursor to get the nls language information for setting the language context */
	CURSOR cur_lang(p_lang_code VARCHAR2) IS
		SELECT nls_language
			FROM fnd_languages
		 WHERE language_code = p_lang_code;
BEGIN
	/* To get the user id details */
	OPEN cur_user;
	FETCH cur_user
		INTO v_user_id;
	IF cur_user%NOTFOUND THEN
		v_return := 'F';
	
	END IF; --IF cur_user%NOTFOUND
	CLOSE cur_user;

	/* To get the responsibility and responsibility application id */
	OPEN cur_resp;
	FETCH cur_resp
		INTO v_resp_id, v_resp_appl_id, v_lang;
	IF cur_resp%NOTFOUND THEN
		v_return := 'F';
	
	END IF; --IF cur_resp%NOTFOUND
	CLOSE cur_resp;

	/* Setting the oracle applications context for the particular session */
	fnd_global.apps_initialize(user_id      => v_user_id,
														 resp_id      => v_resp_id,
														 resp_appl_id => v_resp_appl_id);

	/* Setting the org context for the particular session */
	mo_global.set_policy_context('S', v_org_id);

	/* setting the nls context for the particular session */
	IF v_session_lang != v_lang THEN
		OPEN cur_lang(v_lang);
		FETCH cur_lang
			INTO v_nls_lang;
		CLOSE cur_lang;
		fnd_global.set_nls_context(v_nls_lang);
	END IF; --IF v_session_lang != v_lang

	RETURN v_return;
EXCEPTION
	WHEN OTHERS THEN
		RETURN 'F';
END set_context;

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
  
FUNCTION get_trx_type_id(p_ou_id in NUMBER, p_trx_name in varchar2) RETURN NUMBER IS
    l_cust_trx_type_id NUMBER;
  BEGIN
       SELECT cust_trx_type_id
          INTO l_cust_trx_type_id
          FROM ra_cust_trx_types_all
         WHERE name = p_trx_name
         and type = 'CM'
           AND org_id = p_ou_id
           and rownum = 1;
    RETURN l_cust_trx_type_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN - 1;
  END;  

FUNCTION check_project_code(p_ou_id in NUMBER, p_project_id in number) RETURN Boolean IS
    v_count NUMBER;
  BEGIN
       SELECT count(1)
          INTO v_count
           FROM DEV.FPT_PM_PROJECTS h  
         WHERE h.org_id = p_ou_id
           AND h.project_id = p_PROJECT_ID
          
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
  
FUNCTION check_cust_id(p_ou_id in NUMBER, p_cust_account_id in varchar2) RETURN Boolean IS
    v_count NUMBER;
  BEGIN
       SELECT count(1)
          INTO v_count
           FROM hz_cust_accounts s, hz_cust_acct_sites_all h  
         WHERE s.cust_account_id = h.cust_account_id
           AND h.org_id = p_ou_id
           and h.cust_account_id = p_cust_account_id
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
  
FUNCTION check_bill_to_id(p_ou_id in NUMBER, p_cust_account_id in varchar2, p_bill_to_id number) RETURN Boolean IS
    v_count NUMBER;
  BEGIN
       SELECT count(1)
          INTO v_count
           FROM hz_cust_accounts s, 
                hz_cust_acct_sites_all h, 
                AR.HZ_CUST_SITE_USES_ALL hzc,
                HZ_PARTY_SITES hp                 
         WHERE s.cust_account_id = h.cust_account_id
           AND h.org_id = p_ou_id
           and h.cust_account_id = p_cust_account_id
           and hp.party_site_id = h.party_site_id
           and hzc.cust_acct_site_id = h.cust_acct_site_id
           and hzc.site_use_code = 'BILL_TO'
           and hp.location_id = p_bill_to_id
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
 
procedure ar_Create_Accounting(p_trax_number varchar2, p_tranx_id number) is

	l_accounting_batch_id number; --Out
	p_errbuf              varchar2(100); --Out
	p_retcode             varchar2(100);
	l_request_id          number;
	v_ledger_id           number;
	v_legal_entity_id     number;
	v_org_id              number;
	l_event_source_info   XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;

begin
	select t.legal_entity_id, t.org_id, t.set_of_books_id
		into v_legal_entity_id, v_org_id, v_ledger_id
		from AR.RA_CUSTOMER_TRX_ALL t
	 where t.customer_trx_id = p_tranx_id ---p_cust_transaction_ID
		 and rownum = 1;
	
	--v_ledger_id := get_SOB_ID(v_org_id);

	begin
		--mo_global.init('AR');
		mo_global.set_policy_context('S', v_org_id);
		fnd_global.apps_initialize(user_id      => 0,
															 resp_id      => 20678,
															 resp_appl_id => 222);
	
		l_event_source_info.source_application_id := 222;
		l_event_source_info.application_id        := 222;
		l_event_source_info.legal_entity_id       := v_legal_entity_id;
		l_event_source_info.ledger_id             := v_ledger_id;
		l_event_source_info.entity_type_code      := 'TRANSACTIONS';
		l_event_source_info.transaction_number    := p_trax_number; --RECEIPT_number  draft 8642357
		l_event_source_info.source_id_int_1       := p_tranx_id; --CASH_RECEIPT_ID  862478
	
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
-- Author  : 
-- Created : 3/21/2022 8:21:20 AM
-- Purpose : ar tranx create
procedure fpt_ar_transaction_creation(p_DDP_baolanh      IN DDP_baolanh_Type,
                                      x_return_status             OUT NOCOPY VARCHAR2,
												          		x_msg_count                 OUT NOCOPY NUMBER,
														          x_msg_data                  OUT NOCOPY VARCHAR2,
                                      x_trx_id  OUT NOCOPY  number,
                                      x_trx_number  OUT NOCOPY  varchar2) is
  
    l_index                  NUMBER := 0;
    l_line_index             NUMBER := 0;
    l_dist_index             NUMBER := 0;
    l_cm_customer_trx_id     NUMBER := 0;
    --
    l_batch_source_rec       ar_invoice_api_pub.batch_source_rec_type;
    l_trx_header_tbl         ar_invoice_api_pub.trx_header_tbl_type;
    l_trx_lines_tbl          ar_invoice_api_pub.trx_line_tbl_type;
    l_trx_line_id            NUMBER;
    l_return_status          VARCHAR2 (1);
    l_trx_dist_tbl           ar_invoice_api_pub.trx_dist_tbl_type;
    l_trx_salescredits_tbl   ar_invoice_api_pub.trx_salescredits_tbl_type;
    l_msg_data               VARCHAR2 (2000);
    l_resp_id                NUMBER;
    l_appl_id                NUMBER :=222;
    verr              VARCHAR2 (200);
    g_user_id                fnd_user.user_id%TYPE := 0;
    l_line_number            NUMBER := 0;
    l_msg_count              NUMBER;
    l_ou_id                  hr_operating_units.organization_id%TYPE;
    l_batch_source_id        ra_batch_sources_all.batch_source_id%TYPE;
    l_cust_trx_type_id       ra_cust_trx_types_all.cust_trx_type_id%TYPE ;
    l_cust_account_id        hz_cust_accounts.cust_account_id%TYPE ;
    l_code_combination_id    gl_code_combinations_kfv.code_combination_id%TYPE ; 
    v_DDP_baolanh  DDP_baolanh_Type  := p_DDP_baolanh;
    distribute_ccid             number;
    l_bill_to_site_use_id       number;
    v_project_code     VARCHAR2 (100);
                    
BEGIN

    l_ou_id := v_DDP_baolanh.org_id;  

   /* mo_global.init ('AR');
    mo_global.set_policy_context ('S', l_ou_id);
    fnd_global.apps_initialize (user_id        => 0,
                                resp_id        => 20678,
                                resp_appl_id   => 222);*/

    -- Prepare Credit Memo;
    BEGIN
        SELECT batch_source_id
          INTO l_batch_source_id
          FROM ra_batch_sources_all
         WHERE name = 'MANUAL'
         and org_id = v_DDP_baolanh.org_id;   -- enter the Source name
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.put_line (
                'Error while deriving Batch Source ID: ' || SQLERRM);
    END;
    
    l_batch_source_rec.batch_source_id := l_batch_source_id;
    l_cust_trx_type_id := get_trx_type_id(v_DDP_baolanh.org_id,v_DDP_baolanh.Trnx_type_name);
    
    if v_DDP_baolanh.DISTRIBUTE_ACCOUNT is not null then
    l_code_combination_id := get_ccid_seg1(p_all_segments  => v_DDP_baolanh.DISTRIBUTE_ACCOUNT,
                                  p_org_id        => v_DDP_baolanh.org_id,
                                  p_error_message => verr);
    /*if default_ccid = -1 then
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'GL_ACCOUNT value ' ||
                            v_DDP_baolanh.DISTRIBUTE_ACCOUNT ||
                            ' is not correct!';
      x_ddp_request_code := v_ddp_baolanh_rec_all.ddp_request_code;
      return;
    elsif default_ccid = -2 then
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := 'GL_ACCOUNT value ' ||
                            v_DDP_baolanh.DISTRIBUTE_ACCOUNT || ' ' || verr;
      x_ddp_request_code := v_ddp_baolanh_rec_all.ddp_request_code;
      return;
    end if;*/
  else
    -- Lay TK theo type
     SELECT gl_id_rev
          INTO l_code_combination_id
          FROM ra_cust_trx_types_all
         WHERE name = v_DDP_baolanh.TRNX_TYPE_NAME
         and type = 'CM'
           AND org_id = l_ou_id
           and rownum = 1;
   
  end if;
  
     -- Get Customer Account ID
     l_cust_account_id := v_DDP_baolanh.CUSTOMER_ID;
     if v_DDP_baolanh.BILL_TO_ID is not null then
    BEGIN
				SELECT hzc.site_use_id
					INTO l_bill_to_site_use_id
					FROM hz_cust_accounts         s,
							 hz_cust_acct_sites_all   h,
							 AR.HZ_CUST_SITE_USES_ALL hzc,
							 HZ_PARTY_SITES           hp
				 WHERE s.cust_account_id = h.cust_account_id
					 and h.cust_account_id = l_cust_account_id
					 and h.party_site_id = hp.party_site_id
					 and hzc.cust_acct_site_id = h.cust_acct_site_id
					 and hp.location_id = v_DDP_baolanh.BILL_TO_ID
					 and h.org_id = l_ou_id
					 and rownum = 1;   
           
            EXCEPTION
        WHEN OTHERS
        THEN
           l_bill_to_site_use_id := null;
    END;
    end if;
    -- 
    -- get project code
   begin
   SELECT project_code
          INTO v_project_code
           FROM DEV.FPT_PM_PROJECTS h  
         WHERE h.org_id = v_DDP_baolanh.org_id
           AND h.project_id = v_DDP_baolanh.project_id
           and rownum=1;
  exception when others then
    v_project_code := null;
  end;      
      
    select ra_customer_trx_s.NEXTVAL into
    l_cm_customer_trx_id 
    from dual;
    
    l_index := l_index + 1;
    --
   l_trx_header_tbl (l_index).org_id := l_ou_id;
   l_trx_header_tbl (l_index).trx_header_id := l_cm_customer_trx_id;
    l_trx_header_tbl (l_index).trx_date := TO_DATE(v_DDP_baolanh.trx_date, 'DD/MM/RRRR');
    l_trx_header_tbl (l_index).gl_date :=  TO_DATE (v_DDP_baolanh.gl_date, 'DD/MM/RRRR');
    l_trx_header_tbl (l_index).trx_currency := v_DDP_baolanh.CURRENCY;
    l_trx_header_tbl (l_index).cust_trx_type_id := l_cust_trx_type_id;
    l_trx_header_tbl (l_index).bill_to_customer_id := l_cust_account_id;
    l_trx_header_tbl (l_index).printing_option := 'PRI';
    l_trx_header_tbl (l_index).reference_number := 21220191;
    if   l_trx_header_tbl (l_index).trx_currency <> 'VND' then
    l_trx_header_tbl (l_index).exchange_rate := 23500;
    l_trx_header_tbl (l_index).exchange_rate_type := 'User';
    l_trx_header_tbl (l_index).exchange_date := TO_DATE ('21-03-2022', 'DD-MM-RRRR');
    end if;
    -- bill to site use id
    l_trx_header_tbl (l_index).bill_to_site_use_id := l_bill_to_site_use_id;

    -- Prepare Credit Memo Lines
    l_trx_line_id := ra_customer_trx_lines_s.NEXTVAL;
    l_line_index := l_line_index + 1;
    l_line_number := l_line_number + 1;
    l_dist_index := l_dist_index + 1;
    --
    l_trx_lines_tbl (l_line_index).trx_header_id := l_cm_customer_trx_id;
    l_trx_lines_tbl (l_line_index).trx_line_id := l_trx_line_id;
    l_trx_lines_tbl (l_line_index).line_number := l_line_number;
    l_trx_lines_tbl (l_line_index).quantity_invoiced := 1;
    l_trx_lines_tbl (l_line_index).unit_selling_price := v_DDP_baolanh.unit_selling_price;
    l_trx_lines_tbl (l_line_index).line_type := 'LINE';
    l_trx_lines_tbl (l_line_index).taxable_flag := 'N';
    l_trx_lines_tbl (l_line_index).DESCRIPTION := v_DDP_baolanh.LINE_DESCRIPTION;

    --
    l_trx_dist_tbl (l_dist_index).trx_dist_id   := RA_CUST_TRX_LINE_GL_DIST_S.NEXTVAL;
    l_trx_dist_tbl (l_dist_index).trx_line_id   := l_trx_line_id;
    l_trx_dist_tbl (l_dist_index).ACCOUNT_CLASS := 'REV';
    l_trx_dist_tbl (l_dist_index).percent := 100;
    l_trx_dist_tbl (l_dist_index).code_combination_id := l_code_combination_id;

    l_return_status := NULL;
    
    --Standard API call
    ar_invoice_api_pub.create_invoice (
        p_api_version            => 1.0,
        p_commit                 => fnd_api.g_false,
        p_batch_source_rec       => l_batch_source_rec,
        p_trx_header_tbl         => l_trx_header_tbl,
        p_trx_lines_tbl          => l_trx_lines_tbl,
        p_trx_dist_tbl           => l_trx_dist_tbl,
        p_trx_salescredits_tbl   => l_trx_salescredits_tbl,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data);

    --DBMS_OUTPUT.put_line ('l_return_status is: ' || l_return_status);
    if l_return_status = 'S' then
    select ra_customer_trx_s.currval into
    l_cm_customer_trx_id 
    from dual;
    
    update  AR.RA_CUSTOMER_TRX_ALL x 
    set x.attribute3 = v_DDP_baolanh.SO_HOADON,
        x.attribute6 = v_DDP_baolanh.DIENGIAI,
        x.attribute10 = v_DDP_baolanh.PROJECT_ID
    where  x.customer_trx_id = l_cm_customer_trx_id;
    -- get tran_num
		select x.trx_number
			into x_trx_number
			from AR.RA_CUSTOMER_TRX_ALL x
		 where x.customer_trx_id = l_cm_customer_trx_id;    
     -- get cust_trax_id
     x_trx_id := l_cm_customer_trx_id;
     
      x_return_status    := 'S';
      x_msg_count        := 1;
    end if;     
    COMMIT;
exception when others then
      rollback;
      x_return_status    := 'E';
      x_msg_count        := 1;
      x_msg_data         := sqlerrm;
END;


procedure FPT_DDP_AR_BL(p_DDP_ID              IN VARCHAR2,
												p_DDP_baolanh_Tbl     IN DDP_baolanh_Tbl,
												x_return_status       OUT NOCOPY VARCHAR2,
												x_msg_count           OUT NOCOPY NUMBER,
												x_msg_data            OUT NOCOPY VARCHAR2,
												x_ddp_request_code    OUT NOCOPY VARCHAR2,
												p_DDP_baolanh_Tbl_out OUT NOCOPY DDP_baolanh_Tbl_out
												
												) is

	v_context      boolean := true;
	l_ok_to_cancel boolean;
	verr           VARCHAR2(100);

	l_return_status VARCHAR2(1);
	l_msg_count     NUMBER;
	l_msg_data      VARCHAR2(2000);
	v_invoice_id    number;
	v_count         number;
	v_ddp_id        number;
	v_index         number := p_DDP_baolanh_Tbl.first;
	default_ccid    number;
begin

	--> save point 
	x_return_status := 'S';

	--> check ddp_id in process
	begin
		select count(1)
			into v_count
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'ARMemo_baolanh'
			 and status = 'P';
	exception
		when others then
			v_count := null;
	end;
	if nvl(v_count, 0) > 0 /*and v_status = 'P'*/
	 then
		x_return_status := 'PE';
		x_msg_count     := 1;
		x_msg_data      := 'The request with DDP_ID ' || p_ddp_id ||
											 ' is in processing!!!';
		return;
	end if;
	-----------
	--> check ddp_id da chay roi
	begin
		select count(1)
			into v_count
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'ARMemo_baolanh'
			 and status = 'S';
	exception
		when others then
			v_count := null;
	end;
	if nvl(v_count, 0) > 0 then
		-- tra du lieu khi goi lai ddp_id da chay thanh cong 
		for i in 1 .. p_DDP_baolanh_Tbl.COUNT LOOP
			begin
				select X_TRANSACTION_ID, X_TRX_NUMBER, ddp_request_code
				
					into p_DDP_baolanh_Tbl_out(i).p_Tranx_id,
							 p_DDP_baolanh_Tbl_out(i).p_tranx_number,
							 p_DDP_baolanh_Tbl_out(i).ddp_request_code
					from FPT_DDP_AR_MEMO_BL
				 where ddp_id = p_ddp_id
					 and stt = i;
			exception
				when others then
					null;
			end;
		end loop;
	
		x_return_status := 'S';
		x_msg_count     := 1;
		x_msg_data      := 'ARMemo_baolanh Success!!!';
		return;
	end if;

	--> insert ddp_id
	insert into fpt_ddp_process
		(ddp_id, program, status, start_time)
	values
		(p_ddp_id, 'ARMemo_baolanh', 'P', sysdate);
	----------

	-- check data input

	WHILE v_index <= p_DDP_baolanh_Tbl.LAST LOOP
		-- check type
		if get_trx_type_id(p_DDP_baolanh_Tbl(v_index).org_id,
											 p_DDP_baolanh_Tbl(v_index).Trnx_type_name) = -1 then
			x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := 'Trnx_type_name not exsits';
			x_ddp_request_code := p_DDP_baolanh_Tbl(v_index).ddp_request_code;
			goto STOP;
		end if;
		--check DISTRIBUTE_ACCOUNT
		if p_DDP_baolanh_Tbl(v_index).DISTRIBUTE_ACCOUNT is not null then
			default_ccid := get_ccid_seg1(p_all_segments  => p_DDP_baolanh_Tbl(v_index)
																											 .DISTRIBUTE_ACCOUNT,
																		p_org_id        => p_DDP_baolanh_Tbl(v_index)
																											 .org_id,
																		p_error_message => verr);
			if default_ccid = -1 then
				x_return_status    := 'E';
				x_msg_count        := 1;
				x_msg_data         := 'DISTRIBUTE_ACCOUNT value ' || p_DDP_baolanh_Tbl(v_index)
														 .DISTRIBUTE_ACCOUNT || ' is not correct!';
				x_ddp_request_code := p_DDP_baolanh_Tbl(v_index).ddp_request_code;
				goto STOP;
			elsif default_ccid = -2 then
				x_return_status    := 'E';
				x_msg_count        := 1;
				x_msg_data         := 'DISTRIBUTE_ACCOUNT value ' || p_DDP_baolanh_Tbl(v_index)
														 .DISTRIBUTE_ACCOUNT || ' ' || verr;
				x_ddp_request_code := p_DDP_baolanh_Tbl(v_index).ddp_request_code;
				goto STOP;
			end if;
		end if;
	
		-- check customer_id
		if check_cust_id(p_ou_id           => p_DDP_baolanh_Tbl(v_index).org_id,
										 p_cust_account_id => p_DDP_baolanh_Tbl(v_index)
																					.CUSTOMER_ID) = false then
			x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := 'CUSTOMER_ID or Org_id not corect or not exsits site for customer!!!';
			x_ddp_request_code := p_DDP_baolanh_Tbl(v_index).ddp_request_code;
			goto STOP;
		end if;
		-- check bill_to_id
		if p_DDP_baolanh_Tbl(v_index).BILL_TO_ID is not null and check_bill_to_id(p_ou_id           => p_DDP_baolanh_Tbl(v_index)
																																				 .org_id,
																										p_cust_account_id => p_DDP_baolanh_Tbl(v_index)
																																				 .CUSTOMER_ID,
																										p_bill_to_id      => p_DDP_baolanh_Tbl(v_index)
																																				 .BILL_TO_ID) =
				false then
			x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := 'Bill_to_id not corect !!!';
			x_ddp_request_code := p_DDP_baolanh_Tbl(v_index).ddp_request_code;
			goto STOP;
		end if;
    -- check project code
    if p_DDP_baolanh_Tbl(v_index).PROJECT_ID is not null and check_project_code(p_ou_id => p_DDP_baolanh_Tbl(v_index).org_id, p_project_id => p_DDP_baolanh_Tbl(v_index).PROJECT_ID) = false then
      x_return_status    := 'E';
			x_msg_count        := 1;
			x_msg_data         := 'Project_id not exsits !!!';
			x_ddp_request_code := p_DDP_baolanh_Tbl(v_index).ddp_request_code;
			goto STOP;
     end if;
	
		<<STOP>>
		v_index := v_index + 1;
		exit when x_return_status = 'E';
	end loop;

	if x_return_status = 'E' then
		rollback;
		return;
	end if;

	v_index := p_DDP_baolanh_Tbl.first;
	WHILE v_index <= p_DDP_baolanh_Tbl.LAST LOOP
		-- import CM transaction
    declare
    l_org_id number;
		begin
      l_org_id := p_DDP_baolanh_Tbl(v_index).ORG_ID;
			mo_global.init('AR');
			mo_global.set_policy_context('S', l_org_id);
    --   arp_global.init_global(l_org_id);
      -- arp_standard.init_standard(l_org_id);
     /*set_org_context_in_api(p_org_id => l_org_id,
                            p_return_status => x_return_status);*/
			fnd_global.apps_initialize(user_id      => 0,
																 resp_id      => 20678,
																 resp_appl_id => 222);
		
			fpt_ar_transaction_creation(p_DDP_baolanh   => p_DDP_baolanh_Tbl(v_index),
																	x_return_status => x_return_status,
																	x_msg_count     => x_msg_count,
																	x_msg_data      => x_msg_data,
																	x_trx_id        => p_DDP_baolanh_Tbl_out(v_index)
																										 .p_Tranx_id,
																	x_trx_number    => p_DDP_baolanh_Tbl_out(v_index)
																										 .p_tranx_number);
			p_DDP_baolanh_Tbl_out(v_index).DDP_REQUEST_CODE := p_DDP_baolanh_Tbl(v_index)
																												 .DDP_REQUEST_CODE;
			-- luu du lieu
			if x_return_status = 'S' then
				insert into FPT_DDP_AR_MEMO_BL
					(ddp_id, STT, X_TRANSACTION_ID, X_TRX_NUMBER, ddp_request_code)
				values
					(p_ddp_id,
					 v_index,
					 p_DDP_baolanh_Tbl_out(v_index).p_Tranx_id,
					 p_DDP_baolanh_Tbl_out(v_index).p_tranx_number,
					 p_DDP_baolanh_Tbl_out(v_index).ddp_request_code);
			
			end if;
		end;
    
    v_index := v_index + 1;
		exit when x_return_status = 'E';
	end loop;

	if x_return_status <> 'S' then
		rollback;
		-- Xoa du lieu tra ve
		for i in 1 .. p_DDP_baolanh_Tbl_out.COUNT LOOP
			p_DDP_baolanh_Tbl_out.delete(i);
		end loop;
		return;
	else
		-- create accounting
		for i in 1 .. p_DDP_baolanh_Tbl_out.COUNT LOOP
			-- create accounting AR  
			begin
				ar_Create_Accounting(p_trax_number => p_DDP_baolanh_Tbl_out(i)
																							.p_tranx_number,
														 p_tranx_id    => p_DDP_baolanh_Tbl_out(i)
																							.p_Tranx_id);
			end;
		
		end loop;
	end if;

	--> update trang thai ddp_id
	update fpt_ddp_process
		 set Status = 'S', end_time = sysdate
	 where ddp_id = p_ddp_id
		 and program = 'ARMemo_baolanh';

	x_return_status := 'S';
	x_msg_count     := 1;
	x_msg_data      := 'ARMemo_baolanh Success!!!';

exception
	when others then
		rollback;
		x_return_status := 'E';
		x_msg_count     := 1;
		x_msg_data      := sqlerrm;
	
end;         
     
end FPT_DDP_AR_BL_PUB_V1;
/
