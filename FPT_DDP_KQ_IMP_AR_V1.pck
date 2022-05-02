create or replace package FPT_DDP_KQ_IMP_AR_V1 is

 FUNCTION get_receipt_method_id (p_receipt_method IN VARCHAR2, p_org_id number, P_ERROR_MESSAGE OUT VARCHAR2) return NUMBER  ;
	PROCEDURE CREATE_AR_RECEIPT(KyQuy_Rec         IN FPT_DDP_KQ_IMP_PUB_V1.DDP_Kyquy_Rec_Type,
															p_cash_receipt_id out nocopy number,
															p_receipt_number  out nocopy ar_cash_receipts_all.receipt_number%type);
end FPT_DDP_KQ_IMP_AR_V1;
/
create or replace package body FPT_DDP_KQ_IMP_AR_V1 is
  
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
  
  FUNCTION split_segment(P_SEGMENTS VARCHAR2, P_SEGMENT_NUM NUMBER)
    RETURN VARCHAR2 IS
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
  
    RETURN SUBSTR(P_SEGMENTS,
                  V_FROM_INDEX + 1,
                  V_TO_INDEX - V_FROM_INDEX - 1);
  
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
      P_ERROR_MESSAGE := 'DOES NOT EXIST CHART OF ACCOUNT FOR LEDGER ' ||
                         P_LEDGER_ID;
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

  FUNCTION get_ccid_seg1(P_ALL_SEGMENTS  VARCHAR2,
                         p_org_id        number,
                         P_ERROR_MESSAGE OUT VARCHAR2) RETURN NUMBER IS
    vLedger_Id number;
    vSegment1  varchar2(15);
    vcount     number;
  BEGIN
    vSegment1 := SPLIT_SEGMENT(P_ALL_SEGMENTS, 1);
    select t.SET_OF_BOOKS_ID
      into vLedger_Id
      from fpt_org_company_v t
     where t.SEGMENT1 = vSegment1
       and rownum = 1;
    if p_org_id is not null then
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
    
      if nvl(vcount, 0) = 0 then
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
      P_ERROR_MESSAGE := 'Account not exsits';
      RETURN - 1;
  END;

  
  FUNCTION get_receipt_method_id (p_receipt_method IN VARCHAR2, p_org_id number, P_ERROR_MESSAGE OUT VARCHAR2) return NUMBER IS
    l_receipt_method_id number;
  BEGIN
    Select a.RECEIPT_METHOD_ID into l_receipt_method_id 
      from AR_RECEIPT_METHODS a,
           AR.AR_RECEIPT_METHOD_ACCOUNTS_ALL t 
     where a.receipt_method_id = t.receipt_method_id
       and a.name = p_receipt_method
       and t.org_id = p_org_id ;
    return l_receipt_method_id;
 
 EXCEPTION
    WHEN OTHERS THEN      
      P_ERROR_MESSAGE := 'Receipt method not exist';
      RETURN - 1;
  END;
  
  PROCEDURE CREATE_AR_RECEIPT(KyQuy_Rec IN FPT_DDP_KQ_IMP_PUB_V1.DDP_Kyquy_Rec_Type, 
                               p_cash_receipt_id out nocopy number,
                               p_receipt_number out nocopy ar_cash_receipts_all.receipt_number%type ) IS
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(240);
    l_cash_receipt_id NUMBER;
    p_count           NUMBER;
    l_receipt_number  VARCHAR(100) DEFAULT 'KYQUY_IMP';
    l_misc_dist_tbl   ARP_PROC_RCT_UTIL_V2.misc_dist_tbl_type;
    l_ccid            NUMBER;
    l_receipt_method_id          NUMBER;
    l_attribute_rec                Ar_receipt_api_pub.attribute_rec_type;
    v_rate_type varchar2(10);
    v_exchange_rate number;
    v_segment1  varchar2(100);
    v_resp_id  number;
  BEGIN
    --DBMS_OUTPUT.put_line('1');
   /*v_segment1 := get_segment1(KyQuy_Rec.ORG_ID);
											SELECT responsibility_id
												into v_resp_id
												FROM fnd_responsibility_tl
											 WHERE responsibility_name like
														 'Receivables Manager%'
												 and responsibility_id in
														 (select x.responsibility_id
																from fnd_responsibility x
															 where x.web_host_name = v_segment1
																 and x.application_id = 222
                                 and x.end_date is null);  
                                                     */
             --   mo_global.init('AR');
             --   mo_global.set_policy_context('S', KyQuy_Rec.ORG_ID);
              /*  fnd_global.apps_initialize(user_id      => 0,
                                        resp_id      => 20678,--v_resp_id,
                                         resp_appl_id => 222);*/
  
    l_ccid := get_ccid_seg1(KyQuy_Rec.GL_ACCOUNT,
                            KyQuy_Rec.ORG_ID,
                            l_msg_data);
    
    l_receipt_method_id := get_receipt_method_id (KyQuy_Rec.REC_METHOD,KyQuy_Rec.org_id, l_msg_data);
    
    l_misc_dist_tbl(1).PERCENT := 100;
    l_misc_dist_tbl(1).CODE_COMBINATION_ID := l_ccid;
    -- them so phieu thu va ly do thu
    l_attribute_rec.attribute_category := 'Receipt Informations';
     l_attribute_rec.attribute3 := KyQuy_Rec.REC_SOPHIEUTHU;
     l_attribute_rec.attribute4 := KyQuy_Rec.REC_LYDOTHU;
    --l_receipt_number := KyQuy_Rec.REC_NUMBER;
    if KyQuy_Rec.CURRENCY <> 'VND' then
      v_rate_type := 'User';
      v_exchange_rate := nvl(KyQuy_Rec.RATE,1);
    else
      v_rate_type := null;
      v_exchange_rate := null;
    end if;
    
        
    BEGIN
      ar_receipt_api_v2pub.create_misc(p_api_version        => 1.0,
                                       p_init_msg_list      => fnd_api.G_FALSE,
                                       p_commit             => fnd_api.G_FALSE,
                                       p_validation_level   => fnd_api.g_valid_level_full,
                                       x_return_status      => l_return_status,
                                       x_msg_count          => l_msg_count,
                                       x_msg_data           => l_msg_data,
                                       p_currency_code      => KyQuy_Rec.CURRENCY,
                                       p_exchange_rate_type => v_rate_type,
                                       p_exchange_rate      => v_exchange_rate,
                                       --p_exchange_rate_date => to_date(KyQuy_Rec.INVOICE_DATE,'DD/MM/YYYY'),
                                       p_amount             => KyQuy_Rec.AMOUNT,
                                       p_receipt_date       => to_date(KyQuy_Rec.KYQUY_DATE,'DD/MM/YYYY'),
                                       p_gl_date            => to_date(KyQuy_Rec.KYQUY_DATE,'DD/MM/YYYY'),
                                       p_receipt_method_id  => l_receipt_method_id,
                                       p_activity           => KyQuy_Rec.REC_ACTIVITY,
                                       p_attribute_record => l_attribute_rec,                                 
                                       p_comments           => KyQuy_Rec.REC_COMMENT, 
                                       p_org_id             => KyQuy_Rec.ORG_ID,
                                       p_misc_receipt_id    => l_cash_receipt_id,
                                       p_receipt_number     => l_receipt_number,
                                       p_misc_dist_tbl      => l_misc_dist_tbl);
    
      
    END;
    
    if l_return_status <> 'S' then
      rollback;
    end if;
    p_cash_receipt_id := l_cash_receipt_id;
    p_receipt_number := l_cash_receipt_id;
    
  END;
end FPT_DDP_KQ_IMP_AR_V1;
/
