CREATE OR REPLACE PACKAGE HZ_CUST_ACCOUNTS_V4PUB AUTHID CURRENT_USER AS
/*$Header: HZ_CUST_ACCOUNT_V4PUB.pls 120.12 2006/08/17 10:16:40 idali ship $ */
/*#
 * This package contains the public APIs for customer accounts and related entities.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname  HZ_Customer Accounts 
 * @rep:category BUSINESS_ENTITY HZ_CUSTOMER_ACCOUNT
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS 
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Customer Account APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE cust_acct_rec_all_type IS RECORD (    
    ddp_request_code         VARCHAR2(50),
    customer_type            VARCHAR2(30),    
    account_name             VARCHAR2(240),    
    Acc_comments             VARCHAR2(240), 
    organization_name        VARCHAR2(360),--
    tax_reference            VARCHAR2(50), 
    country                  VARCHAR2(60),--
    address1                 VARCHAR2(240),
    address2                 VARCHAR2(240),
    city                     VARCHAR2(60),  
    state                    VARCHAR2(60),
    province                 VARCHAR2(60),
    county                   VARCHAR2(60),
    country_bill             VARCHAR2(60),--
    address1_bill            VARCHAR2(240),
    address2_bill            VARCHAR2(240),
    city_bill                VARCHAR2(60),                    
    state_bill               VARCHAR2(60),
    province_bill            VARCHAR2(60),
    county_bill              VARCHAR2(60),
    country_ship             VARCHAR2(60),--
    address1_ship            VARCHAR2(240),
    address2_ship            VARCHAR2(240),
    city_ship                VARCHAR2(60),
    state_ship               VARCHAR2(60),
    province_ship            VARCHAR2(60),
    county_ship              VARCHAR2(60),
    validated_flag           VARCHAR2(1),
    party_site_name          VARCHAR2(240),--
    site_use_comments        VARCHAR2(240),--
    site_use_type            VARCHAR2(30),    
    primary_per_type         VARCHAR2(1), 
    site_use_code            VARCHAR2(30),--
    primary_flag             VARCHAR2(1),
    gl_rec                   VARCHAR2(50),
    gl_rev                   VARCHAR2(50),
    gl_tax                   VARCHAR2(50),
    status                   VARCHAR2(1),--
    created_by_module        VARCHAR2(150),
    application_id           NUMBER    
);

TYPE cust_acct_tbl_all_type IS TABLE OF cust_acct_rec_all_type INDEX BY BINARY_INTEGER;

TYPE cust_Rec_Type_out IS RECORD
  (
   ddp_request_code         VARCHAR2(50),
   x_cust_account_id       NUMBER,
    x_account_number       VARCHAR2(30), 
    x_bill_location_id     NUMBER,
    x_ship_location_id    NUMBER   );
   
TYPE cust_tbl_Type_out IS TABLE OF cust_Rec_Type_out INDEX BY BINARY_INTEGER;


TYPE cust_acct_rec_upd_all_type IS RECORD (    
    ddp_request_code         VARCHAR2(50),
    account_number           VARCHAR2(30),
    account_name             VARCHAR2(240),    
    Acc_comments             VARCHAR2(240), 
    organization_name        VARCHAR2(360),--
    tax_reference            VARCHAR2(50), 
    Acc_Status               VARCHAR2(1),
    location_id              number,---
    country                  VARCHAR2(60),
    address1                 VARCHAR2(240),
    address2                 VARCHAR2(240),
    city                     VARCHAR2(60),  
    state                    VARCHAR2(60),
    province                 VARCHAR2(60),
    county                   VARCHAR2(60),
    location_id_bill         number,---
    country_bill             VARCHAR2(60),
    address1_bill            VARCHAR2(240),
    address2_bill            VARCHAR2(240),
    city_bill                VARCHAR2(60),
    state_bill               VARCHAR2(60),
    province_bill            VARCHAR2(60),
    county_bill              VARCHAR2(60),
    location_id_ship         number,---                    
    country_ship             VARCHAR2(60),
    address1_ship            VARCHAR2(240),
    address2_ship            VARCHAR2(240),
    city_ship                VARCHAR2(60), 
    state_ship               VARCHAR2(60),
    province_ship            VARCHAR2(60),
    county_ship              VARCHAR2(60),
    gl_rec                   VARCHAR2(50),
    gl_rev                   VARCHAR2(50),
    gl_tax                   VARCHAR2(50), 
    primary_flag             VARCHAR2(1),   
    created_by_module        VARCHAR2(150),
    application_id           NUMBER,
    org_id                   number    
);

TYPE cust_acct_tbl_upd_all_type IS TABLE OF cust_acct_rec_upd_all_type INDEX BY BINARY_INTEGER;

TYPE cust_Rec_upd_Type_out IS RECORD
  (
    ddp_request_code         VARCHAR2(50),
    x_bill_location_id     NUMBER,
    x_ship_location_id    NUMBER   );
   
TYPE cust_tbl_upd_Type_out IS TABLE OF cust_Rec_upd_Type_out INDEX BY BINARY_INTEGER;
/*
---FUNCTION split_segment(P_SEGMENTS VARCHAR2, P_SEGMENT_NUM NUMBER) RETURN VARCHAR2;
---FUNCTION get_ccid_seg(P_ALL_SEGMENTS VARCHAR2, P_ERROR_MESSAGE OUT VARCHAR2) RETURN NUMBER;
*/
--------------------------------------
-- declaration of public procedures and functions
--------------------------------------
/**
 * PROCEDURE create_customer_accounts_all
 *
 * DESCRIPTION
 *     Creates customer account for Org party.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_PARTY_V2PUB.create_person
 *     HZ_CUSTOMER_PROFIE_V2PUB.create_customer_profile
 *     HZ_LOCATION_V2PUB.create_location
 *     HZ_PARTY_SITE_V2PUB.create_party_site
 *     HZ_PARTY_SITE_V2PUB.create_party_site_use
 *     HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site
 *     HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_tbl_all            Customer account record. 
 *   IN/OUT:
 *   OUT:
 *     p_cust_tbl_Type_out              Customer account ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   10-12-2021    BangTX      o Created.
 *
 */


/*#
 * Use this routine to create a customer account. The API creates records in the
 * HZ_CUST_ACCOUNTS table for the Person party type. You can create a customer account for
 * an existing party by passing the party_id value of the party. Alternatively, this
 * routine creates a new party and an account for that party. You can also create a
 * customer profile record in the HZ_CUSTOMER_PROFILES table, while calling this routine
 * based on value passed in p_customer_profile_rec. This routine is overloaded for Person
 * and Organization. If an orig_system_reference is passed in, then the API creates a
 * record in the HZ_ORIG_SYS_REFERENCES table to store the mapping between the source
 * system reference and the TCA primary key. If orig_system_reference is not passed in,
 * then the default is UNKNOWN. 
 * @param p_ddp_id batch ID.
 
 * @param p_init_msg_list Initialize message stack if it is set to
 * FND_API.G_TRUE. Default is FND_API.G_FALSE
 * @param p_cust_acct_tbl_all Customer accounts. 
 * @param p_cust_tbl_Type_out Customer account ID, account number, bill to,ship to output.

 * @param x_return_status Return status after the call. The status can
 * be FND_API.G_RET_STS_SUCCESS (success),
 * FND_API.G_RET_STS_ERROR (error),
 * FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Message text if x_msg_count is 1.
 * @param x_ddp_request_code   ddp_request_code loi
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Accounts  (For Org party)
 * @rep:businessevent oracle.apps.ar.hz.CustAccounts.create
 * @rep:doccd 120hztig.pdf Customer Account APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
 
PROCEDURE create_batch_cust_account_all (
    p_ddp_id                                in VARCHAR2,
   
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_tbl_all                     IN     cust_acct_tbl_all_type,    
    p_cust_tbl_Type_out                      OUT NOCOPY   cust_tbl_Type_out,  
     
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2,
    x_ddp_request_code         OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE update_customer_account_all
 *
 * DESCRIPTION
 *     Updates customer account for Org party.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_PARTY_V2PUB.create_person
 *     HZ_CUSTOMER_PROFIE_V2PUB.create_customer_profile
 *     HZ_LOCATION_V2PUB.create_location
 *     HZ_PARTY_SITE_V2PUB.create_party_site
 *     HZ_PARTY_SITE_V2PUB.create_party_site_use
 *     HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site
 *     HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_rec_all            Customer account record. 
 *   IN/OUT:
 *   OUT:      
 *     x_bill_location_id             Location of bill.
 *     x_ship_location_id             Location of ship.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   10-12-2021    BangTX      o Created.
 *
 */
/*#
 * Use this routine to update a customer account. This API updates records in the
 * HZ_CUST_ACCOUNTS table. The customer account can belong to a party of type
 * Person or Organization. The same routine updates all types of accounts,
 * whether the account belongs to a person or an organization. If the primary key is not
 * passed in, then get the primary key from the HZ_ORIG_SYS_REFERENCES table, based on
 * orig_system and orig_system_reference. Note: orig_system and orig_system_reference must
 * be unique and not null and unique.
 * @param p_ddp_id batch ID.
 
 * @param p_init_msg_list Initialize message stack if it is set to
 * FND_API.G_TRUE. Default is FND_API.G_FALSE
 * @param p_cust_acct_tbl_upd_all Customer accounts. 
 * @param p_cust_tbl_upd_Type_out  bill to, ship to output.
 
 * @param x_return_status Return status after the call. The status can
 * be FND_API.G_RET_STS_SUCCESS (success),
 * FND_API.G_RET_STS_ERROR (error),
 * FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Message text if x_msg_count is 1.
 * @param x_ddp_request_code   ddp_request_code loi
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Account
 * @rep:businessevent oracle.apps.ar.hz.CustAccount.update
 * @rep:doccd 120hztig.pdf Customer Account APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_customer_account_all (
    p_ddp_id                                in VARCHAR2,
  
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_tbl_upd_all                 IN     cust_acct_tbl_upd_all_type,    
    p_cust_tbl_upd_Type_out                 OUT NOCOPY    cust_tbl_upd_Type_out,
    
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2,
    x_ddp_request_code         OUT NOCOPY VARCHAR2
);

END HZ_CUST_ACCOUNTS_V4PUB;
/
CREATE OR REPLACE PACKAGE BODY HZ_CUST_ACCOUNTS_V4PUB AS
/*$Header: ARH2CASB.pls 120.38.12010000.2 2009/08/21 01:28:13 awu ship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

--G_DEBUG_COUNT             NUMBER := 0;
--G_DEBUG                   BOOLEAN := FALSE;

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/
/*-------------------------------------------- 
   Insert Log
    
*/


/*Procedure erp_insert_table_log(p_RESPONSE varchar2,p_REQEUST_NAME varchar2,p_DES varchar2,
                                 p_REQUEST_DATE date,p_START_DATE varchar2,END_DATE varchar2) is
    begin
      return;
      insert into FPT_REQUEST_LOG(ID,RESPONSE,REQEUST_NAME,DES,REQUEST_DATE,START_DATE,END_DATE)
        values(FPT_REQUEST_LOG_S.Nextval,p_RESPONSE,p_REQEUST_NAME,p_DES,p_REQUEST_DATE,p_START_DATE,END_DATE);
        commit;
    end;*/
/*-------------------------------------------- 
   Get CCID
    
*/
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
  
FUNCTION get_ccid_seg(P_ALL_SEGMENTS VARCHAR2, P_ERROR_MESSAGE OUT VARCHAR2)
    RETURN NUMBER IS
    vLedger_Id number;
    vSegment1  varchar2(15);
  BEGIN
    vSegment1 := SPLIT_SEGMENT(P_ALL_SEGMENTS, 1);
    select t.SET_OF_BOOKS_ID into vLedger_Id from fpt_org_company_v t
     where t.SEGMENT1 = vSegment1 and rownum = 1;
      
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

FUNCTION get_ccid_seg1(P_ALL_SEGMENTS VARCHAR2, p_org_id number, P_ERROR_MESSAGE OUT VARCHAR2)
    RETURN NUMBER IS
    vLedger_Id number;
    vSegment1  varchar2(15);
    vcompnay_code varchar2(15);
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
/*-------------------------------------------- 
   Customer Account
   x_location_id_b: Bill To
   x_location_id_s: Ship To
    
*/
Procedure create_location
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_all_type,  
    x_location_id                           OUT NOCOPY    NUMBER, 
    x_location_id_b                         OUT NOCOPY    NUMBER, 
    x_location_id_s                         OUT NOCOPY    NUMBER,  
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is  
 vlocation_rec     HZ_LOCATION_V2PUB.location_rec_type;
Begin                                    
  -->Insert log
  FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Location Bill',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
  
  -->Tao Bill To Location
  if p_cust_acct_rec_all.country_bill is not null then
    vlocation_rec.country := p_cust_acct_rec_all.country_bill;  
    vlocation_rec.address1 := p_cust_acct_rec_all.address1_bill;
    vlocation_rec.address2 := p_cust_acct_rec_all.address2_bill;
    vlocation_rec.city := p_cust_acct_rec_all.city_bill;
    vlocation_rec.state := p_cust_acct_rec_all.state_bill;
    vlocation_rec.province := p_cust_acct_rec_all.province_bill;
    vlocation_rec.county := p_cust_acct_rec_all.county_bill;
    
    vlocation_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
    vlocation_rec.application_id := p_cust_acct_rec_all.application_id;
    
    HZ_LOCATION_V2PUB.create_location(p_init_msg_list => p_init_msg_list,
                                      p_location_rec  => vlocation_rec,
                                      x_location_id   => x_location_id_b,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data);  
  end if;
                                   
  -->Insert log
  FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Location Ship',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
  
  if p_cust_acct_rec_all.country_ship is not null then
    vlocation_rec.country := p_cust_acct_rec_all.country_ship;  
    vlocation_rec.address1 := p_cust_acct_rec_all.address1_ship;
    vlocation_rec.address2 := p_cust_acct_rec_all.address2_ship;
    vlocation_rec.city := p_cust_acct_rec_all.city_ship;
    vlocation_rec.state := p_cust_acct_rec_all.state_ship;
    vlocation_rec.province := p_cust_acct_rec_all.province_ship;
    vlocation_rec.county := p_cust_acct_rec_all.county_ship;
    -->Ship To Location
    HZ_LOCATION_V2PUB.create_location(p_init_msg_list => p_init_msg_list,
                                      p_location_rec  => vlocation_rec,
                                      x_location_id   => x_location_id_s,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data);    
  
  end if;
  
  -->If exists location bill/ship then assign it to cust location
  if x_location_id_b is not null or x_location_id_s is not null then
    x_location_id := nvl(x_location_id_b,x_location_id_s);
  else
    -->Insert log
    FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Location',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
    -->Tao Location
    vlocation_rec.country := nvl(p_cust_acct_rec_all.country,'VN');  
    vlocation_rec.address1 := p_cust_acct_rec_all.address1;
    vlocation_rec.address2 := p_cust_acct_rec_all.address2;
    vlocation_rec.city := p_cust_acct_rec_all.city;
    vlocation_rec.state := p_cust_acct_rec_all.state;
    vlocation_rec.province := p_cust_acct_rec_all.province;
    vlocation_rec.county := p_cust_acct_rec_all.county;
    vlocation_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
    vlocation_rec.application_id := p_cust_acct_rec_all.application_id;
    
    HZ_LOCATION_V2PUB.create_location(p_init_msg_list => p_init_msg_list,
                                      p_location_rec  => vlocation_rec,
                                      x_location_id   => x_location_id,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data); 
  end if;
End;   
/*-------------------------------------------- 
   Customer Account
*/
Procedure create_cust_account
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_all_type,  
    x_cust_account_id                       OUT NOCOPY    NUMBER, 
    x_account_number                        OUT NOCOPY    VARCHAR2,    
    x_party_id                              OUT NOCOPY    NUMBER,     
    x_profile_id                            OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
 vCust_account_rec HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type;
 vOrganization_rec HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
 vCustomer_profile_rec HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
 vParty_number     VARCHAR2(30);
 
Begin
  -->Insert log
  FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Create Customer',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
  -->Tao Customer Account
  vCust_account_rec.customer_type := p_cust_acct_rec_all.customer_type;
  vCust_account_rec.account_name := p_cust_acct_rec_all.account_name; 
  vCust_account_rec.comments := p_cust_acct_rec_all.Acc_comments;
  vCust_account_rec.status := p_cust_acct_rec_all.status;
  vCust_account_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
  vCust_account_rec.application_id := p_cust_acct_rec_all.application_id;  
  vOrganization_rec.organization_name := p_cust_acct_rec_all.organization_name;
  vOrganization_rec.tax_reference := p_cust_acct_rec_all.tax_reference;
  vOrganization_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
  vOrganization_rec.application_id := p_cust_acct_rec_all.application_id;  
  vCustomer_profile_rec.status := p_cust_acct_rec_all.status;
  vCustomer_profile_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
  vCustomer_profile_rec.application_id := p_cust_acct_rec_all.application_id;
  
  HZ_CUST_ACCOUNT_V2PUB.create_cust_account(p_init_msg_list        => p_init_msg_list,
                                            p_cust_account_rec     => vCust_account_rec,
                                            p_organization_rec     => vOrganization_rec,
                                            p_customer_profile_rec => vCustomer_profile_rec,
                                            p_create_profile_amt   => 'T',
                                            x_cust_account_id      => x_cust_account_id,
                                            x_account_number       => x_account_number,
                                            x_party_id             => x_party_id,
                                            x_party_number         => vParty_number,
                                            x_profile_id           => x_profile_id,
                                            x_return_status        => x_return_status,
                                            x_msg_count            => x_msg_count,
                                            x_msg_data             => x_msg_data);
End;
/*-------------------------------------------- 
   Party site
*/
Procedure create_cust_party_site
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_all_type,  
    p_party_id                              IN  Number,
    p_location_id                           IN  Number,
    x_party_site_id                         OUT NOCOPY    NUMBER,    
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
 vParty_site_rec       HZ_PARTY_SITE_V2PUB.party_site_rec_type;
 vParty_site_number    varchar2(30);
Begin
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Create party site',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao party site
   vParty_site_rec.party_id := p_party_id;
   vParty_site_rec.location_id := p_location_id;
   vParty_site_rec.status := p_cust_acct_rec_all.status;
   vParty_site_rec.party_site_name := p_cust_acct_rec_all.party_site_name;   
   vParty_site_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
   vParty_site_rec.application_id := p_cust_acct_rec_all.application_id;
  
   HZ_PARTY_SITE_V2PUB.create_party_site(p_init_msg_list     => p_init_msg_list,
                                         p_party_site_rec    => vParty_site_rec,
                                         x_party_site_id     => x_party_site_id,
                                         x_party_site_number => vParty_site_number,
                                         x_return_status     => x_return_status,
                                         x_msg_count         => x_msg_count,
                                         x_msg_data          => x_msg_data);
End;

/*-------------------------------------------- 
   Party site
*/
Procedure create_cust_party_site2
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_upd_all_type,  
    p_party_id                              IN  Number,
    p_location_id                           IN  Number,
    x_party_site_id                         OUT NOCOPY    NUMBER,    
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
 vParty_site_rec       HZ_PARTY_SITE_V2PUB.party_site_rec_type;
 vParty_site_number    varchar2(30);
Begin
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Create party site',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao party site
   vParty_site_rec.party_id := p_party_id;
   vParty_site_rec.location_id := p_location_id;
   vParty_site_rec.status := 'A';
   vParty_site_rec.party_site_name := 'Auto by API';   
   vParty_site_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
   vParty_site_rec.application_id := p_cust_acct_rec_all.application_id;
  
   HZ_PARTY_SITE_V2PUB.create_party_site(p_init_msg_list     => p_init_msg_list,
                                         p_party_site_rec    => vParty_site_rec,
                                         x_party_site_id     => x_party_site_id,
                                         x_party_site_number => vParty_site_number,
                                         x_return_status     => x_return_status,
                                         x_msg_count         => x_msg_count,
                                         x_msg_data          => x_msg_data);
End;

/*-------------------------------------------- 
   Party site use
*/
Procedure create_cust_party_site_use
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_all_type,  
    p_Party_Site_Id                         IN  Number,    
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
 vParty_site_use_rec   HZ_PARTY_SITE_V2PUB.party_site_use_rec_type;
 vParty_site_use_id number;
Begin
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Create party site use',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao party site use
   vParty_site_use_rec.comments := p_cust_acct_rec_all.site_use_comments;
   vParty_site_use_rec.site_use_type := 'BILL_TO';
   vParty_site_use_rec.party_site_id := p_Party_Site_Id;
   vParty_site_use_rec.primary_per_type := p_cust_acct_rec_all.primary_per_type;
   vParty_site_use_rec.status := p_cust_acct_rec_all.status;
   vParty_site_use_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
   vParty_site_use_rec.application_id := p_cust_acct_rec_all.application_id;
   
   HZ_PARTY_SITE_V2PUB.create_party_site_use(p_init_msg_list      => p_init_msg_list,
                                             p_party_site_use_rec => vParty_site_use_rec,
                                             x_party_site_use_id  => vParty_site_use_id,
                                             x_return_status      => x_return_status,
                                             x_msg_count          => x_msg_count,
                                             x_msg_data           => x_msg_data);
End;


/*-------------------------------------------- 
   Cust Acct site 
*/
Procedure create_cust_acc_site
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_all_type, 
    p_cust_account_id                       IN  Number,  
    p_Party_Site_Id                         IN  Number,   
    x_Cust_Acc_site_Id                      OUT NOCOPY    NUMBER, 
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
 vCust_acct_site_rec   HZ_CUST_ACCOUNT_SITE_V2PUB.cust_acct_site_rec_type;
Begin
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Create Customer Account Site',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao Customer Account Site
   vCust_acct_site_rec.cust_account_id := p_cust_account_id;
   vCust_acct_site_rec.party_site_id := p_Party_Site_Id;
   vCust_acct_site_rec.status := p_cust_acct_rec_all.status;
   vCust_acct_site_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
   vCust_acct_site_rec.application_id := p_cust_acct_rec_all.application_id;
   
   HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site(p_init_msg_list      => p_init_msg_list,
                                                    p_cust_acct_site_rec => vCust_acct_site_rec,
                                                    x_cust_acct_site_id  => x_Cust_Acc_site_Id,
                                                    x_return_status      => x_return_status,
                                                    x_msg_count          => x_msg_count,
                                                    x_msg_data           => x_msg_data);
End;

---------For all orgs
Procedure create_cust_acc_site1
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_all_type, 
    p_org_id                                IN  Number, 
    p_cust_account_id                       IN  Number,  
    p_Party_Site_Id                         IN  Number,   
    x_Cust_Acc_site_Id                      OUT NOCOPY    NUMBER, 
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
 vCust_acct_site_rec   HZ_CUST_ACCOUNT_SITE_V2PUB.cust_acct_site_rec_type;
 v_org_id number := p_org_id;
Begin
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Create Customer Account Site',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao Customer Account Site
   vCust_acct_site_rec.cust_account_id := p_cust_account_id;
   vCust_acct_site_rec.party_site_id := p_Party_Site_Id;
   vCust_acct_site_rec.status := p_cust_acct_rec_all.status;
   vCust_acct_site_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
   vCust_acct_site_rec.application_id := p_cust_acct_rec_all.application_id;
   --- them org_id
   vCust_acct_site_rec.org_id := v_org_id;
   
   HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site(p_init_msg_list      => p_init_msg_list,
                                                    p_cust_acct_site_rec => vCust_acct_site_rec,
                                                    x_cust_acct_site_id  => x_Cust_Acc_site_Id,
                                                    x_return_status      => x_return_status,
                                                    x_msg_count          => x_msg_count,
                                                    x_msg_data           => x_msg_data);
End;


/*-------------------------------------------- 
   Cust Acct site 
*/
Procedure create_cust_acc_site2
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_upd_all_type, 
    p_org_id                                IN  Number default null,
    p_cust_account_id                       IN  Number,  
    p_Party_Site_Id                         IN  Number,   
    x_Cust_Acc_site_Id                      OUT NOCOPY    NUMBER, 
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
 vCust_acct_site_rec   HZ_CUST_ACCOUNT_SITE_V2PUB.cust_acct_site_rec_type;
Begin
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Create Customer Account Site',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao Customer Account Site
   vCust_acct_site_rec.cust_account_id := p_cust_account_id;
   vCust_acct_site_rec.party_site_id := p_Party_Site_Id;
   vCust_acct_site_rec.status := 'A';
   vCust_acct_site_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
   vCust_acct_site_rec.application_id := p_cust_acct_rec_all.application_id;
   --- them org_id
   if p_org_id is not null then
   vCust_acct_site_rec.org_id := p_org_id;
   end if;
   HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site(p_init_msg_list      => p_init_msg_list,
                                                    p_cust_acct_site_rec => vCust_acct_site_rec,
                                                    x_cust_acct_site_id  => x_Cust_Acc_site_Id,
                                                    x_return_status      => x_return_status,
                                                    x_msg_count          => x_msg_count,
                                                    x_msg_data           => x_msg_data);
End;

/*-------------------------------------------- 
   Cust Acct site use
*/
Procedure create_cust_acc_site_use
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_all_type, 
    p_Cust_Acc_site_Id                      IN  Number,  
    p_Location_BILL_Id                      IN  Number,   
    p_Location_SHIP_Id                      IN  Number,   
    p_Profile_id                            IN  Number,  
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
 vCust_acct_site_use_rec HZ_CUST_ACCOUNT_SITE_V2PUB.cust_site_use_rec_type;
 vCustomer_profile_rec HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
 vCust_Acc_site_use_Id number;
 vGl_Rec_Id            number;
 vGl_Rev_Id            number;
 vGl_Tax_Id            number;
 vErr                  varchar2(1000);
Begin
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Lay tk GL',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Lay tai khoan Rec
   if p_cust_acct_rec_all.gl_rec is not null then
     vGl_Rec_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_rec, P_ERROR_MESSAGE => vErr);
     if vGl_Rec_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REC: ' || vErr;
       --RAISE FND_API.G_EXC_ERROR; 
       return;
     end if;
   end if;   
   -->Lay tai khoan Rev
   if p_cust_acct_rec_all.gl_rev is not null then
     vGl_Rev_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_rev, P_ERROR_MESSAGE => vErr);
     if vGl_Rev_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REV: ' || vErr;
       ---RAISE FND_API.G_EXC_ERROR; 
       return;
     end if;
   end if;
   -->Lay tai khoan Tax
   if p_cust_acct_rec_all.gl_tax is not null then
     vGl_Tax_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_tax, P_ERROR_MESSAGE => vErr);
     if vGl_Tax_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_TAX: ' || vErr;
       --RAISE FND_API.G_EXC_ERROR; 
       return;
     end if;
   end if;
       
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Create Customer Account Site Use for Bill To',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao Customer Account Site Use for Bill To
   if p_Location_BILL_Id is not null then
     vCust_acct_site_use_rec.cust_acct_site_id := p_Cust_Acc_site_Id;
     vCust_acct_site_use_rec.site_use_code := 'BILL_TO';
     vCust_acct_site_use_rec.primary_flag := p_cust_acct_rec_all.primary_flag;
     vCust_acct_site_use_rec.status := p_cust_acct_rec_all.status;
    -- vCust_acct_site_use_rec.location := p_Location_BILL_Id;
     vCust_acct_site_use_rec.gl_id_rec := vGl_Rec_Id;
     vCust_acct_site_use_rec.gl_id_rev := vGl_Rev_Id; 
     vCust_acct_site_use_rec.gl_id_tax := vGl_Tax_Id;
     vCust_acct_site_use_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCust_acct_site_use_rec.application_id := p_cust_acct_rec_all.application_id;
     
     vCustomer_profile_rec.cust_account_profile_id := p_Profile_id;
     vCustomer_profile_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCustomer_profile_rec.application_id := p_cust_acct_rec_all.application_id;
     
     HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use(p_init_msg_list        => p_init_msg_list,
                                                     p_cust_site_use_rec    => vCust_acct_site_use_rec,
                                                     p_customer_profile_rec => vCustomer_profile_rec,
                                                     p_create_profile       => 'T',
                                                     p_create_profile_amt   => 'T',
                                                     x_site_use_id          => vCust_Acc_site_use_Id,
                                                     x_return_status        => x_return_status,
                                                     x_msg_count            => x_msg_count,
                                                     x_msg_data             => x_msg_data);   
   end if;
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Create Customer Account Site Use for Ship To',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao Customer Account Site Use for Ship To
   if p_Location_SHIP_Id is not null then
     vCust_acct_site_use_rec.cust_acct_site_id := p_Cust_Acc_site_Id;
     vCust_acct_site_use_rec.site_use_code := 'SHIP_TO';
     vCust_acct_site_use_rec.primary_flag := p_cust_acct_rec_all.primary_flag;
     vCust_acct_site_use_rec.status := p_cust_acct_rec_all.status;
   --  vCust_acct_site_use_rec.location := p_Location_SHIP_Id;
     vCust_acct_site_use_rec.gl_id_rec := '';
     vCust_acct_site_use_rec.gl_id_rev := ''; 
     vCust_acct_site_use_rec.gl_id_tax := ''; 
     vCust_acct_site_use_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCust_acct_site_use_rec.application_id := p_cust_acct_rec_all.application_id;
     vCust_acct_site_use_rec.bill_to_site_use_id := vCust_Acc_site_use_Id;
     vCustomer_profile_rec.cust_account_profile_id := p_Profile_id;
     vCustomer_profile_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCustomer_profile_rec.application_id := p_cust_acct_rec_all.application_id;
     
     HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use(p_init_msg_list        => p_init_msg_list,
                                                     p_cust_site_use_rec    => vCust_acct_site_use_rec,
                                                     p_customer_profile_rec => vCustomer_profile_rec,
                                                     p_create_profile       => 'F',
                                                     p_create_profile_amt   => 'F',
                                                     x_site_use_id          => vCust_Acc_site_use_Id,
                                                     x_return_status        => x_return_status,
                                                     x_msg_count            => x_msg_count,
                                                     x_msg_data             => x_msg_data); 
  end if;
End;

--------For all Orgs
Procedure create_cust_acc_site_use1
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_all_type, 
    p_org_id                                IN  Number, 
    p_Cust_Acc_site_Id                      IN  Number,  
    p_Location_BILL_Id                      IN  Number,   
    p_Location_SHIP_Id                      IN  Number,   
    p_Profile_id                            IN  Number,  
    x_Acc_site_use_Id                       IN  number,
    x_Acc_site_use_out_Id                   OUT number,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
 vCust_acct_site_use_rec HZ_CUST_ACCOUNT_SITE_V2PUB.cust_site_use_rec_type;
 vCustomer_profile_rec HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
 vCust_Acc_site_use_Id number ;
 vGl_Rec_Id            number;
 vGl_Rev_Id            number;
 vGl_Tax_Id            number;
 vErr                  varchar2(1000);
 v_org_id number := p_org_id;
Begin
  vCust_Acc_site_use_Id := null;
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Lay tk GL',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Lay tai khoan Rec
   if p_cust_acct_rec_all.gl_rec is not null then
     vGl_Rec_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_rec, P_ERROR_MESSAGE => vErr);
     if vGl_Rec_Id = -1 then
       /*x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REC: ' || vErr;*/
       vGl_Rec_Id := null;
      
       --RAISE FND_API.G_EXC_ERROR; 
       --return;
     end if;
   end if;   
   -->Lay tai khoan Rev
   if p_cust_acct_rec_all.gl_rev is not null then
     vGl_Rev_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_rev, P_ERROR_MESSAGE => vErr);
     if vGl_Rev_Id = -1 then
       /*x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REV: ' || vErr;*/
       vGl_Rev_Id := null;
       ---RAISE FND_API.G_EXC_ERROR; 
      -- return;
     end if;
   end if;
   -->Lay tai khoan Tax
   if p_cust_acct_rec_all.gl_tax is not null then
     vGl_Tax_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_tax, P_ERROR_MESSAGE => vErr);
     if vGl_Tax_Id = -1 then
      /* x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_TAX: ' || vErr;*/
       vGl_Tax_Id := null;
       --RAISE FND_API.G_EXC_ERROR; 
       --return;
     end if;
   end if;
       
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Create Customer Account Site Use for Bill To',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao Customer Account Site Use for Bill To
   if p_Location_BILL_Id is not null then
     vCust_acct_site_use_rec.cust_acct_site_id := p_Cust_Acc_site_Id;
     vCust_acct_site_use_rec.site_use_code := 'BILL_TO';
     vCust_acct_site_use_rec.primary_flag := p_cust_acct_rec_all.primary_flag;
     vCust_acct_site_use_rec.status := p_cust_acct_rec_all.status;
     --- them org_id
     vCust_acct_site_use_rec.org_id := v_org_id;
    -- vCust_acct_site_use_rec.location := p_Location_BILL_Id;
     vCust_acct_site_use_rec.gl_id_rec := vGl_Rec_Id;
     vCust_acct_site_use_rec.gl_id_rev := vGl_Rev_Id; 
     vCust_acct_site_use_rec.gl_id_tax := vGl_Tax_Id;
     vCust_acct_site_use_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCust_acct_site_use_rec.application_id := p_cust_acct_rec_all.application_id;
     
     vCustomer_profile_rec.cust_account_profile_id := p_Profile_id;
     vCustomer_profile_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCustomer_profile_rec.application_id := p_cust_acct_rec_all.application_id;
     
     
     HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use(p_init_msg_list        => p_init_msg_list,
                                                     p_cust_site_use_rec    => vCust_acct_site_use_rec,
                                                     p_customer_profile_rec => vCustomer_profile_rec,
                                                     p_create_profile       => 'F',
                                                     p_create_profile_amt   => 'F',
                                                     x_site_use_id          => vCust_Acc_site_use_Id,
                                                     x_return_status        => x_return_status,
                                                     x_msg_count            => x_msg_count,
                                                     x_msg_data             => x_msg_data);   
   x_Acc_site_use_out_Id := vCust_Acc_site_use_Id;
   end if;
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Create Customer Account Site Use for Ship To',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao Customer Account Site Use for Ship To
   if p_Location_SHIP_Id is not null then
     vCust_acct_site_use_rec.cust_acct_site_id := p_Cust_Acc_site_Id;
     vCust_acct_site_use_rec.site_use_code := 'SHIP_TO';
     vCust_acct_site_use_rec.primary_flag := p_cust_acct_rec_all.primary_flag;
     vCust_acct_site_use_rec.status := p_cust_acct_rec_all.status;
     --- them org_id
     vCust_acct_site_use_rec.org_id := v_org_id;
   --  vCust_acct_site_use_rec.location := p_Location_SHIP_Id;
     vCust_acct_site_use_rec.gl_id_rec := '';
     vCust_acct_site_use_rec.gl_id_rev := ''; 
     vCust_acct_site_use_rec.gl_id_tax := ''; 
     vCust_acct_site_use_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCust_acct_site_use_rec.application_id := p_cust_acct_rec_all.application_id;
     if x_Acc_site_use_Id is null then
     vCust_acct_site_use_rec.bill_to_site_use_id := vCust_Acc_site_use_Id;
     else
       vCust_acct_site_use_rec.bill_to_site_use_id := x_Acc_site_use_Id;
       end if;
     vCustomer_profile_rec.cust_account_profile_id := p_Profile_id;
     vCustomer_profile_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCustomer_profile_rec.application_id := p_cust_acct_rec_all.application_id;
     
     HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use(p_init_msg_list        => p_init_msg_list,
                                                     p_cust_site_use_rec    => vCust_acct_site_use_rec,
                                                     p_customer_profile_rec => vCustomer_profile_rec,
                                                     p_create_profile       => 'F',
                                                     p_create_profile_amt   => 'F',
                                                     x_site_use_id          => vCust_Acc_site_use_Id,
                                                     x_return_status        => x_return_status,
                                                     x_msg_count            => x_msg_count,
                                                     x_msg_data             => x_msg_data); 
  end if;
End;


/*-------------------------------------------- 
   Cust Acct site use
*/
Procedure create_cust_acc_site_use2
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_upd_all_type, 
    p_org_id                                IN  Number default null,
    p_Cust_Acc_site_Id                      IN  Number,  
    p_Location_BILL_Id                      IN  Number,   
    p_Location_SHIP_Id                      IN  Number,   
    p_Profile_id                            IN  Number,  
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
 vCust_acct_site_use_rec HZ_CUST_ACCOUNT_SITE_V2PUB.cust_site_use_rec_type;
 vCustomer_profile_rec HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
 vCust_Acc_site_use_Id number;
 vGl_Rec_Id            number;
 vGl_Rev_Id            number;
 vGl_Tax_Id            number;
 vErr                  varchar2(1000);
 --
 
Begin
  vCust_Acc_site_use_Id := '';
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Lay tk GL',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Lay tai khoan Rec
   if p_cust_acct_rec_all.gl_rec is not null then
     vGl_Rec_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_rec, P_ERROR_MESSAGE => vErr);
     if vGl_Rec_Id = -1 then
       /*x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REC: ' || vErr;*/
       vGl_Rec_Id := null;
       --RAISE FND_API.G_EXC_ERROR;
      -- return; 
     end if;
   end if;   
   -->Lay tai khoan Rev
   if p_cust_acct_rec_all.gl_rev is not null then
     vGl_Rev_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_rev, P_ERROR_MESSAGE => vErr);
     if vGl_Rev_Id = -1 then
       /*x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REV: ' || vErr;*/
       --RAISE FND_API.G_EXC_ERROR; 
       --return;
       vGl_Rev_Id := null;
     end if;
   end if;
   -->Lay tai khoan Tax
   if p_cust_acct_rec_all.gl_tax is not null then
     vGl_Tax_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_tax, P_ERROR_MESSAGE => vErr);
     if vGl_Tax_Id = -1 then
       /*x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_TAX: ' || vErr;*/
       --RAISE FND_API.G_EXC_ERROR; 
       ---return;
       vGl_Tax_Id := null;
     end if;
   end if;
       
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Create Customer Account Site Use for Bill To',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao Customer Account Site Use for Bill To
   if p_Location_BILL_Id is not null then
     vCust_acct_site_use_rec.cust_acct_site_id := p_Cust_Acc_site_Id;
     vCust_acct_site_use_rec.site_use_code := 'BILL_TO';
     vCust_acct_site_use_rec.primary_flag := p_cust_acct_rec_all.primary_flag;
     vCust_acct_site_use_rec.status := 'A';
      --- them org_id
      if p_org_id is not null then
     vCust_acct_site_use_rec.org_id := p_org_id;
     end if;
     --vCust_acct_site_use_rec.location := p_Location_BILL_Id;
     vCust_acct_site_use_rec.gl_id_rec := vGl_Rec_Id;
     vCust_acct_site_use_rec.gl_id_rev := vGl_Rev_Id; 
     vCust_acct_site_use_rec.gl_id_tax := vGl_Tax_Id;
     vCust_acct_site_use_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCust_acct_site_use_rec.application_id := p_cust_acct_rec_all.application_id;
     
     vCustomer_profile_rec.cust_account_profile_id := p_Profile_id;
     vCustomer_profile_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCustomer_profile_rec.application_id := p_cust_acct_rec_all.application_id;
     
     HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use(p_init_msg_list        => p_init_msg_list,
                                                     p_cust_site_use_rec    => vCust_acct_site_use_rec,
                                                     p_customer_profile_rec => vCustomer_profile_rec,
                                                     p_create_profile       => 'F',
                                                     p_create_profile_amt   => 'F',
                                                     x_site_use_id          => vCust_Acc_site_use_Id,
                                                     x_return_status        => x_return_status,
                                                     x_msg_count            => x_msg_count,
                                                     x_msg_data             => x_msg_data);   
   end if;
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Create Customer Account Site Use for Ship To',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Tao Customer Account Site Use for Ship To
   if p_Location_SHIP_Id is not null then
     -- lay site_use_id cua Bill to muon gan cho Ship to 
      if nvl(vCust_Acc_site_use_Id,0) = 0 and nvl(p_cust_acct_rec_all.location_id_bill,0) != 0  then
				begin
					select hzu.site_use_id
						into vCust_Acc_site_use_Id
						from HZ_CUST_SITE_USES_ALL  hzu,
								 HZ_CUST_ACCT_SITES_ALL hzc,
                 HZ_CUST_ACCOUNTS  hca,
								 HZ_PARTY_SITES         hza
					 where hzc.cust_acct_site_id = hzu.cust_acct_site_id
						 and hzc.party_site_id = hza.party_site_id
             and hca.cust_account_id = hzc.cust_account_id
						 and hca.account_number = p_cust_acct_rec_all.account_number
             and hzu.Org_id = hzc.Org_Id
						 and hzu.site_use_code = 'BILL_TO'
						 and hzu.Org_id = p_org_id
						 and hza.location_id = p_cust_acct_rec_all.location_id_bill
             and rownum =1;
				exception
					when others then
						/*x_return_status := 'E';
						x_msg_count     := 1;
						x_msg_data      := 'The Location_id of Bill_to Address is not correct!!!';
						--rollback;
            return;*/
            vCust_Acc_site_use_Id := '';
				end;      
          end if;
         
     vCust_acct_site_use_rec.cust_acct_site_id := p_Cust_Acc_site_Id;
     vCust_acct_site_use_rec.site_use_code := 'SHIP_TO';
     vCust_acct_site_use_rec.primary_flag := p_cust_acct_rec_all.primary_flag;
     vCust_acct_site_use_rec.status := 'A';
      if p_org_id is not null then
     vCust_acct_site_use_rec.org_id := p_org_id;
     end if;
     --vCust_acct_site_use_rec.location := p_Location_SHIP_Id;
     vCust_acct_site_use_rec.gl_id_rec := '';
     vCust_acct_site_use_rec.gl_id_rev := ''; 
     vCust_acct_site_use_rec.gl_id_tax := ''; 
     vCust_acct_site_use_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCust_acct_site_use_rec.application_id := p_cust_acct_rec_all.application_id;
     vCust_acct_site_use_rec.bill_to_site_use_id := vCust_Acc_site_use_Id;
     vCustomer_profile_rec.cust_account_profile_id := p_Profile_id;
     vCustomer_profile_rec.created_by_module := p_cust_acct_rec_all.created_by_module;
     vCustomer_profile_rec.application_id := p_cust_acct_rec_all.application_id;
     
     HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use(p_init_msg_list        => p_init_msg_list,
                                                     p_cust_site_use_rec    => vCust_acct_site_use_rec,
                                                     p_customer_profile_rec => vCustomer_profile_rec,
                                                     p_create_profile       => 'F',
                                                     p_create_profile_amt   => 'F',
                                                     x_site_use_id          => vCust_Acc_site_use_Id,
                                                     x_return_status        => x_return_status,
                                                     x_msg_count            => x_msg_count,
                                                     x_msg_data             => x_msg_data); 
  
  end if;
End;

/*-------------------------------------------- 
   Create Customer Account all
*/
PROCEDURE create_customer_account_all(
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_all_type,
    x_cust_account_id                       OUT NOCOPY    NUMBER,
    x_account_number                        OUT NOCOPY    VARCHAR2,
    x_bill_location_id                      OUT NOCOPY    NUMBER,
    x_ship_location_id                      OUT NOCOPY    NUMBER,   
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is
 vLocation_Id      number;                         
 vLocation_BILL_Id number;
 vLocation_SHIP_Id number; 
 vParty_Id         number;
 vParty_Site_Id    number; 
 vCust_Acc_site_Id number; 
 vProfile_id       number;
 vCheck_Tax        number;
 vCheck_country_code number;
 
Begin
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Begin',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   
    --> Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    
    -->Check tax_reference for cust. If exists then return
    select count(1) into vCheck_Tax from hz_parties hp, hz_cust_accounts hca
     where hp.tax_reference = p_cust_acct_rec_all.tax_reference
       and hp.party_id = hca.party_id;
    if vCheck_Tax > 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Customer (with this tax_reference) exists.';
      return;
      --RAISE FND_API.G_EXC_ERROR;
    end if;
    --> check country code
    if p_cust_acct_rec_all.country_bill is not null then
			select count(1)
				into vCheck_country_code
				from fnd_territories_tl
			 where territory_code = p_cust_acct_rec_all.country_bill;  
     if nvl(vCheck_country_code,0) = 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Country Code of Bill to address is not correct !!!';
      return;
        end if;
    end if;
    
    if p_cust_acct_rec_all.country_ship is not null then
			select count(1)
				into vCheck_country_code
				from fnd_territories_tl
			 where territory_code = p_cust_acct_rec_all.country_ship;  
     if nvl(vCheck_country_code,0) = 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Country Code of Ship to address is not correct !!!';
      return;
        end if;
    end if;
      
   -->Tao Location   
   create_location( p_init_msg_list       => p_init_msg_list,
                    p_cust_acct_rec_all   => p_cust_acct_rec_all, 
                    x_location_id         => vLocation_Id,  
                    x_location_id_b       => vLocation_BILL_Id, 
                    x_location_id_s       => vLocation_SHIP_Id,  
                    x_return_status       => x_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   x_bill_location_id := vLocation_BILL_Id;
   x_ship_location_id := vLocation_SHIP_Id;
   -->Tao Customer Account
   create_cust_account( p_init_msg_list       => p_init_msg_list,
                        p_cust_acct_rec_all   => p_cust_acct_rec_all,
                        x_cust_account_id     => x_cust_account_id,   
                        x_account_number      => x_account_number,  
                        x_party_id            => vParty_Id,     
                        x_profile_id          => vProfile_id,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   
   
   -->Tao party site
   create_cust_party_site(p_init_msg_list       => p_init_msg_list,
                          p_cust_acct_rec_all   => p_cust_acct_rec_all,  
                          p_party_id            => vParty_Id,
                          p_location_id         => vLocation_Id,
                          x_party_site_id       => vParty_Site_Id,    
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
  /* -->Tao party site use
   create_cust_party_site_use(p_init_msg_list       => p_init_msg_list,
                              p_cust_acct_rec_all   => p_cust_acct_rec_all, 
                              p_Party_Site_Id       => vParty_Site_Id,    
                              x_return_status       => x_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;*/
   -->Tao Customer Account Site
   create_cust_acc_site(p_init_msg_list       => p_init_msg_list,
                        p_cust_acct_rec_all   => p_cust_acct_rec_all, 
                        p_cust_account_id     => x_cust_account_id,  
                        p_Party_Site_Id       => vParty_Site_Id,   
                        x_Cust_Acc_site_Id    => vCust_Acc_site_Id, 
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   -->Tao Customer Account Site Use 
   --> Bill to v? Ship To c?ng ch?ng d?a ch? Bill to
   if vLocation_BILL_Id is not null and vLocation_SHIP_Id is null then
     ---> ch? t?o Bill To
     if p_cust_acct_rec_all.site_use_type is null then
     create_cust_acc_site_use(p_init_msg_list       => p_init_msg_list,
                              p_cust_acct_rec_all   => p_cust_acct_rec_all, 
                              p_Cust_Acc_site_Id    => vCust_Acc_site_Id,  
                              p_Location_BILL_Id    => vLocation_BILL_Id,   
                              p_Location_SHIP_Id    => '',   
                              p_Profile_id          => vProfile_id,  
                              x_return_status       => x_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data);
     else
       --> t?o c? Bill to, Ship to
       create_cust_acc_site_use(p_init_msg_list       => p_init_msg_list,
                              p_cust_acct_rec_all   => p_cust_acct_rec_all, 
                              p_Cust_Acc_site_Id    => vCust_Acc_site_Id,  
                              p_Location_BILL_Id    => vLocation_BILL_Id,   
                              p_Location_SHIP_Id    => vLocation_BILL_Id,   
                              p_Profile_id          => vProfile_id,  
                              x_return_status       => x_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data);
       x_ship_location_id := vLocation_BILL_Id;
       end if;
     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
       rollback;
       return;
     end if;
    
   --> ??a ch? Ship to  kh?c d?a ch? Bill
   else
     create_cust_acc_site_use(p_init_msg_list       => p_init_msg_list,
                              p_cust_acct_rec_all   => p_cust_acct_rec_all, 
                              p_Cust_Acc_site_Id    => vCust_Acc_site_Id,  
                              p_Location_BILL_Id    => vLocation_BILL_Id,
                              p_Location_SHIP_Id    => '',                                  
                              p_Profile_id          => vProfile_id,  
                              x_return_status       => x_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data);
     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
       rollback;
       return;
     end if;
    -->Tao party site cho Ship To
   create_cust_party_site(p_init_msg_list       => p_init_msg_list,
                          p_cust_acct_rec_all   => p_cust_acct_rec_all,  
                          p_party_id            => vParty_Id,
                          p_location_id         => vLocation_SHIP_Id,
                          x_party_site_id       => vParty_Site_Id,    
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   -->Tao Customer Account Site cho Ship To
   create_cust_acc_site(p_init_msg_list       => p_init_msg_list,
                        p_cust_acct_rec_all   => p_cust_acct_rec_all, 
                        p_cust_account_id     => x_cust_account_id,  
                        p_Party_Site_Id       => vParty_Site_Id,   
                        x_Cust_Acc_site_Id    => vCust_Acc_site_Id, 
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   -->Tao Customer Account Site Use cho Ship To
     create_cust_acc_site_use(p_init_msg_list       => p_init_msg_list,
                              p_cust_acct_rec_all   => p_cust_acct_rec_all, 
                              p_Cust_Acc_site_Id    => vCust_Acc_site_Id,
                              p_Location_BILL_Id    => '',                                 
                              p_Location_SHIP_Id    => vLocation_SHIP_Id,   
                              p_Profile_id          => vProfile_id,  
                              x_return_status       => x_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data);
     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
       rollback;
       return;
     end if;

   end if;
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','End',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);       
  
/*EXCEPTION WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);    */                              
End;
/*-------------------------------------------- 
   Customer Account
   x_location_id_b: Bill To
   x_location_id_s: Ship To
    
*/
--------Procedure to create customer for all orgs
PROCEDURE create_customer_account_all1(
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_all_type,
    x_cust_account_id                       OUT NOCOPY    NUMBER,
    x_account_number                        OUT NOCOPY    VARCHAR2,
    x_bill_location_id                      OUT NOCOPY    NUMBER,
    x_ship_location_id                      OUT NOCOPY    NUMBER,   
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is
 vLocation_Id      number;                         
 vLocation_BILL_Id number;
 vLocation_SHIP_Id number; 
 vParty_Id         number;
 vParty_Site_Id    number; 
 vParty_Site_Ship_Id number;
 vCust_Acc_site_Id number; 
 vCust_Acc_site_Ship_Id number;
 v_Acc_site_use_Id number;
 vProfile_id       number;
 vCheck_Tax        number;
 vCheck_country_code number;
 
 v_cust_acct_rec_all cust_acct_rec_all_type := p_cust_acct_rec_all;
Begin
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','Begin',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   --- lay gia tri mac dinh 
     v_cust_acct_rec_all.created_by_module := 'HZ_CPUI';
     v_cust_acct_rec_all.application_id := '222';
    
    --> Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   
    -->Check tax_reference for cust. If exists then return
    select count(1) into vCheck_Tax from hz_parties hp, hz_cust_accounts hca
     where hp.tax_reference = v_cust_acct_rec_all.tax_reference
       and hp.party_id = hca.party_id;
    if vCheck_Tax > 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Customer (with this tax_reference) exists.';
      return;
      --RAISE FND_API.G_EXC_ERROR;
    end if;
    --> check country code
    if v_cust_acct_rec_all.country_bill is not null then
			select count(1)
				into vCheck_country_code
				from fnd_territories_tl
			 where territory_code = v_cust_acct_rec_all.country_bill;  
     if nvl(vCheck_country_code,0) = 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Country Code of Bill to address is not correct !!!';
      return;
        end if;
    end if;
    
    if v_cust_acct_rec_all.country_ship is not null then
			select count(1)
				into vCheck_country_code
				from fnd_territories_tl
			 where territory_code = v_cust_acct_rec_all.country_ship;  
     if nvl(vCheck_country_code,0) = 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Country Code of Ship to address is not correct !!!';
      return;
        end if;
    end if;
      
   -->Tao Location   
   create_location( p_init_msg_list       => p_init_msg_list,
                    p_cust_acct_rec_all   => v_cust_acct_rec_all, 
                    x_location_id         => vLocation_Id,  
                    x_location_id_b       => vLocation_BILL_Id, 
                    x_location_id_s       => vLocation_SHIP_Id,  
                    x_return_status       => x_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   x_bill_location_id := vLocation_BILL_Id;
   x_ship_location_id := vLocation_SHIP_Id;
   -->Tao Customer Account chung
   create_cust_account( p_init_msg_list       => p_init_msg_list,
                        p_cust_acct_rec_all   => v_cust_acct_rec_all,
                        x_cust_account_id     => x_cust_account_id,   
                        x_account_number      => x_account_number,  
                        x_party_id            => vParty_Id,     
                        x_profile_id          => vProfile_id,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   
   
   -->Tao party site for bill
   create_cust_party_site(p_init_msg_list       => p_init_msg_list,
                          p_cust_acct_rec_all   => v_cust_acct_rec_all,  
                          p_party_id            => vParty_Id,
                          p_location_id         => vLocation_Id,
                          x_party_site_id       => vParty_Site_Id,    
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
  /* -->Tao party site use
   create_cust_party_site_use(p_init_msg_list       => p_init_msg_list,
                              p_cust_acct_rec_all   => p_cust_acct_rec_all, 
                              p_Party_Site_Id       => vParty_Site_Id,    
                              x_return_status       => x_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;*/
   
   
   ---> tao site use cho ship khi vLocation_SHIP_Id not null
   if vLocation_SHIP_Id is not null then
    -->Tao party site cho Ship To
   create_cust_party_site(p_init_msg_list       => p_init_msg_list,
                          p_cust_acct_rec_all   => v_cust_acct_rec_all,  
                          p_party_id            => vParty_Id,
                          p_location_id         => vLocation_SHIP_Id,
                          x_party_site_id       => vParty_Site_Ship_Id,    
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   
     end if; 
     
   -->Tao Customer Account Site  cho tung org
   for i in (select org_id, segment1, set_of_books_id, description from fpt_company_code_7_org order by org_id) loop
     v_cust_acct_rec_all.gl_rec := p_cust_acct_rec_all.gl_rec;
     v_cust_acct_rec_all.gl_rev := p_cust_acct_rec_all.gl_rev;
     v_cust_acct_rec_all.gl_tax := p_cust_acct_rec_all.gl_tax;
     
     if v_cust_acct_rec_all.gl_rec is not null then
     v_cust_acct_rec_all.gl_rec := to_char(i.segment1 || substr(v_cust_acct_rec_all.gl_rec,7));
     end if;
     if v_cust_acct_rec_all.gl_rec is not null then
     v_cust_acct_rec_all.gl_rev := to_char(i.segment1 || substr(v_cust_acct_rec_all.gl_rev,7));
     end if;
     if v_cust_acct_rec_all.gl_rec is not null then
     v_cust_acct_rec_all.gl_tax := to_char(i.segment1 || substr(v_cust_acct_rec_all.gl_tax,7));
     end if;
     --
     vCust_Acc_site_Id := '';  -- tra ve null
     vCust_Acc_site_Ship_Id := '';
     v_Acc_site_use_Id := '';
     
     -->Tao Customer Account Site
     create_cust_acc_site1(p_init_msg_list       => p_init_msg_list,
                        p_cust_acct_rec_all   => v_cust_acct_rec_all, 
                        p_org_id              => i.org_id,
                        p_cust_account_id     => x_cust_account_id,  
                        p_Party_Site_Id       => vParty_Site_Id,   
                        x_Cust_Acc_site_Id    => vCust_Acc_site_Id, 
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   
   --> Bill to v? Ship To c?ng ch?ng d?a ch? Bill to
   if vLocation_BILL_Id is not null and vLocation_SHIP_Id is null then
     ---> Only Bill To
     if p_cust_acct_rec_all.site_use_type is null then
     create_cust_acc_site_use1(p_init_msg_list       => p_init_msg_list,
                              p_cust_acct_rec_all   => v_cust_acct_rec_all,
                              p_org_id              => i.org_id, 
                              p_Cust_Acc_site_Id    => vCust_Acc_site_Id,  
                              p_Location_BILL_Id    => vLocation_BILL_Id,   
                              p_Location_SHIP_Id    => '',   
                              p_Profile_id          => vProfile_id,
                              x_Acc_site_use_Id     => '',  
                              x_Acc_site_use_out_Id => v_Acc_site_use_Id,
                              x_return_status       => x_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data);
     else
       --> In Case Bill to = Ship to
       create_cust_acc_site_use1(p_init_msg_list       => p_init_msg_list,
                              p_cust_acct_rec_all   => v_cust_acct_rec_all, 
                              p_org_id              => i.org_id,
                              p_Cust_Acc_site_Id    => vCust_Acc_site_Id,  
                              p_Location_BILL_Id    => vLocation_BILL_Id,   
                              p_Location_SHIP_Id    => vLocation_BILL_Id,   
                              p_Profile_id          => vProfile_id, 
                              x_Acc_site_use_Id     => '',  
                              x_Acc_site_use_out_Id => v_Acc_site_use_Id,
                              x_return_status       => x_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data);
       x_ship_location_id := vLocation_BILL_Id;
       end if;
     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
       rollback;
       return;
     end if;
    
   --> in Case Bill to <> Ship to
   else
     -- Bill to site use 
    create_cust_acc_site_use1(p_init_msg_list       => p_init_msg_list,
                              p_cust_acct_rec_all   => v_cust_acct_rec_all, 
                              p_org_id              => i.org_id,
                              p_Cust_Acc_site_Id    => vCust_Acc_site_Id,  
                              p_Location_BILL_Id    => vLocation_BILL_Id,
                              p_Location_SHIP_Id    => '',                                  
                              p_Profile_id          => vProfile_id,  
                              x_Acc_site_use_Id     => '', 
                              x_Acc_site_use_out_Id => v_Acc_site_use_Id,
                              x_return_status       => x_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data);
     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
       rollback;
       return;
     end if;
  
   -->Tao Customer Account Site cho Ship To
      --- cust site for Ship to (use Ship party site)
   create_cust_acc_site1(p_init_msg_list       => p_init_msg_list,
                        p_cust_acct_rec_all   => v_cust_acct_rec_all, 
                        p_org_id              => i.org_id,
                        p_cust_account_id     => x_cust_account_id,  
                        p_Party_Site_Id       => vParty_Site_Ship_Id,   
                        x_Cust_Acc_site_Id    => vCust_Acc_site_Ship_Id, 
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   -->Tao Customer Account Site Use cho Ship To
        -- site use for Ship to
     create_cust_acc_site_use1(p_init_msg_list       => p_init_msg_list,
                              p_cust_acct_rec_all   => v_cust_acct_rec_all,
                              p_org_id              => i.org_id,
                              p_Cust_Acc_site_Id    => vCust_Acc_site_Ship_Id,
                              p_Location_BILL_Id    => '',                                 
                              p_Location_SHIP_Id    => vLocation_SHIP_Id,   
                              p_Profile_id          => vProfile_id,  
                              x_Acc_site_use_Id     => v_Acc_site_use_Id, 
                              x_Acc_site_use_out_Id => v_Acc_site_use_Id,
                              x_return_status       => x_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data);
                              
     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
       rollback;
       return;
     end if;

   end if;
   end loop;
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','CREATE CUSTOMER','End',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);       
  
                           
End;

Procedure update_location
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_upd_all                 IN     cust_acct_rec_upd_all_type,      
    x_location_id_b                         OUT NOCOPY    NUMBER, 
    x_location_id_s                         OUT NOCOPY    NUMBER,  
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is  
 vlocation_rec     HZ_LOCATION_V2PUB.location_rec_type;
 vObject_version_number number;
Begin
  -->Insert log
  FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Location',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
  
 -- vlocation_rec.created_by_module := p_cust_acct_rec_upd_all.created_by_module;
  --vlocation_rec.application_id := p_cust_acct_rec_upd_all.application_id;
    
  -->Update Cust Location
  if p_cust_acct_rec_upd_all.location_id is not null then
    vlocation_rec.location_id := p_cust_acct_rec_upd_all.location_id;
    vlocation_rec.country := nvl(p_cust_acct_rec_upd_all.country,'VN');  
    vlocation_rec.address1 := p_cust_acct_rec_upd_all.address1;
    vlocation_rec.address2 := p_cust_acct_rec_upd_all.address2;
    vlocation_rec.city := p_cust_acct_rec_upd_all.city;
    vlocation_rec.state := p_cust_acct_rec_upd_all.state;
    vlocation_rec.province := p_cust_acct_rec_upd_all.province;
    vlocation_rec.county := p_cust_acct_rec_upd_all.county;   
    
    -->Lay object_version_number, require
    select hl.object_version_number into vObject_version_number from hz_locations hl 
     where hl.location_id = p_cust_acct_rec_upd_all.location_id;
      -- get created_by_module, application_id
     select hl.created_by_module, hl.application_id
			 into vlocation_rec.created_by_module,
           vlocation_rec.application_id 
			 from hz_locations hl
			where hl.location_id = p_cust_acct_rec_upd_all.location_id;
      
    HZ_LOCATION_V2PUB.update_location(p_init_msg_list         => p_init_msg_list,
                                      p_location_rec          => vlocation_rec,
                                      p_object_version_number => vObject_version_number,
                                      x_return_status         => x_return_status,
                                      x_msg_count             => x_msg_count,
                                      x_msg_data              => x_msg_data);     
                                    
  end if;
  -->Insert log
  FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Location Bill',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
  
  -->Update Cust Location
  if p_cust_acct_rec_upd_all.location_id_bill is not null and p_cust_acct_rec_upd_all.country_bill is not null  then
    vlocation_rec.location_id := p_cust_acct_rec_upd_all.location_id_bill;
    vlocation_rec.country := p_cust_acct_rec_upd_all.country_bill;  
    vlocation_rec.address1 := p_cust_acct_rec_upd_all.address1_bill;
    vlocation_rec.address2 := p_cust_acct_rec_upd_all.address2_bill;
    vlocation_rec.city := p_cust_acct_rec_upd_all.city_bill;    
    vlocation_rec.state := p_cust_acct_rec_upd_all.state_bill;
    vlocation_rec.province := p_cust_acct_rec_upd_all.province_bill;
    vlocation_rec.county := p_cust_acct_rec_upd_all.county_bill;
     -->Lay object_version_number, created_by_module, application_id require
		begin
			select hl.object_version_number,  hl.created_by_module, hl.application_id
				into vObject_version_number,
              vlocation_rec.created_by_module,
           vlocation_rec.application_id 
				from hz_locations hl
			 where hl.location_id = p_cust_acct_rec_upd_all.location_id_bill;
		exception
			when others then
				x_return_status := 'E';
				x_msg_count     := 1;
				x_msg_data      := 'location id ' ||
													 p_cust_acct_rec_upd_all.location_id_bill ||
													 ' not found!!!';
				return;
		end;  
    
    HZ_LOCATION_V2PUB.update_location(p_init_msg_list         => p_init_msg_list,
                                      p_location_rec          => vlocation_rec,
                                      p_object_version_number => vObject_version_number,
                                      x_return_status         => x_return_status,
                                      x_msg_count             => x_msg_count,
                                      x_msg_data              => x_msg_data);     
                                    
  else
    -->Tao moi Bill location
    if p_cust_acct_rec_upd_all.location_id_bill is  null and p_cust_acct_rec_upd_all.country_bill is not null  then
      vlocation_rec.country := p_cust_acct_rec_upd_all.country_bill;  
      vlocation_rec.address1 := p_cust_acct_rec_upd_all.address1_bill;
      vlocation_rec.address2 := p_cust_acct_rec_upd_all.address2_bill;
      vlocation_rec.city := p_cust_acct_rec_upd_all.city_bill;
      vlocation_rec.state := p_cust_acct_rec_upd_all.state_bill;
      vlocation_rec.province := p_cust_acct_rec_upd_all.province_bill;
      vlocation_rec.county := p_cust_acct_rec_upd_all.county_bill;
      vlocation_rec.created_by_module := p_cust_acct_rec_upd_all.created_by_module;
      vlocation_rec.application_id := p_cust_acct_rec_upd_all.application_id;
      
      HZ_LOCATION_V2PUB.create_location(p_init_msg_list => p_init_msg_list,
                                        p_location_rec  => vlocation_rec,
                                        x_location_id   => x_location_id_b,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data);
    end if;
  end if;
  -->Insert log
  FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Location Ship',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
  
  if p_cust_acct_rec_upd_all.location_id_ship is not null then
    vlocation_rec.location_id := p_cust_acct_rec_upd_all.location_id_ship;
    vlocation_rec.country := nvl(p_cust_acct_rec_upd_all.country_ship,'VN');  
    vlocation_rec.address1 := p_cust_acct_rec_upd_all.address1_ship;
    vlocation_rec.address2 := p_cust_acct_rec_upd_all.address2_ship;
    vlocation_rec.city := p_cust_acct_rec_upd_all.city_ship; 
    vlocation_rec.state := p_cust_acct_rec_upd_all.state_ship;
    vlocation_rec.province := p_cust_acct_rec_upd_all.province_ship;
    vlocation_rec.county := p_cust_acct_rec_upd_all.county_ship;   
    
     -->Lay object_version_number, require
		begin
			select hl.object_version_number, hl.created_by_module, hl.application_id
				into vObject_version_number,
              vlocation_rec.created_by_module,
           vlocation_rec.application_id 
				from hz_locations hl
			 where hl.location_id = p_cust_acct_rec_upd_all.location_id_ship;
		exception
			when others then
				x_return_status := 'E';
				x_msg_count     := 1;
				x_msg_data      := 'location id ' ||
													 p_cust_acct_rec_upd_all.location_id_ship ||
													 ' not found!!!';
				return;
		end;    
    
    HZ_LOCATION_V2PUB.update_location(p_init_msg_list         => p_init_msg_list,
                                      p_location_rec          => vlocation_rec,
                                      p_object_version_number => vObject_version_number,
                                      x_return_status         => x_return_status,
                                      x_msg_count             => x_msg_count,
                                      x_msg_data              => x_msg_data);   
  else
    -->Tao moi Ship location
    if p_cust_acct_rec_upd_all.country_ship is not null then
      if p_cust_acct_rec_upd_all.country_bill is null then
      vlocation_rec.country := p_cust_acct_rec_upd_all.country_ship;  
      vlocation_rec.address1 := p_cust_acct_rec_upd_all.address1_ship;
      vlocation_rec.address2 := p_cust_acct_rec_upd_all.address2_ship;
      vlocation_rec.city := p_cust_acct_rec_upd_all.city_ship;
      vlocation_rec.state := p_cust_acct_rec_upd_all.state_ship;
      vlocation_rec.province := p_cust_acct_rec_upd_all.province_ship;
      vlocation_rec.county := p_cust_acct_rec_upd_all.county_ship;
        vlocation_rec.created_by_module := p_cust_acct_rec_upd_all.created_by_module;
      vlocation_rec.application_id := p_cust_acct_rec_upd_all.application_id;
      
      
      HZ_LOCATION_V2PUB.create_location(p_init_msg_list => p_init_msg_list,
                                        p_location_rec  => vlocation_rec,
                                        x_location_id   => x_location_id_s,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data);
    else
      -- bill, ship cung dia chi
       x_location_id_s := x_location_id_b;
    end if;
   end if;  
                                    
  end if;
End;   
/*-------------------------------------------- 
   Update Customer Account
*/
Procedure update_cust_account
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_upd_all_type,  
    p_cust_account_id                       IN    NUMBER,
    p_party_id                              IN    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
 vCust_account_rec HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type;
 vOrganization_rec HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE; 
 vParty_rec        HZ_PARTY_V2PUB.party_rec_type;
 vObj_ver_num_cus  number;
 vObj_ver_num_org  number;
 vProfile_id       number;
 v_created_by_module varchar(20);
 v_application_id number;
Begin
  -->Insert log
  FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Update Customer',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
  -->Lay version cua Customer, Organization
	select hca.object_version_number,
				 hca.created_by_module,
				hca.application_id
		into vObj_ver_num_cus,
				 v_created_by_module,
				v_application_id
		from hz_cust_accounts hca
	 where hca.cust_account_id = p_cust_account_id; 
	 select hp.object_version_number
		 into vObj_ver_num_org
		 from hz_parties hp
		where hp.party_id = p_party_id;   
  -->Update Customer Account  
  vCust_account_rec.cust_account_id := p_cust_account_id;
  vCust_account_rec.account_name := p_cust_acct_rec_all.account_name; 
  vCust_account_rec.comments := p_cust_acct_rec_all.Acc_comments;
  vCust_account_rec.status := p_cust_acct_rec_all.Acc_Status;
  vCust_account_rec.created_by_module := v_created_by_module; --p_cust_acct_rec_all.created_by_module;
  vCust_account_rec.application_id := v_application_id;  
  
  HZ_CUST_ACCOUNT_V2PUB.update_cust_account(p_init_msg_list         => p_init_msg_list,
                                            p_cust_account_rec      => vCust_account_rec,
                                            p_object_version_number => vObj_ver_num_cus,
                                            x_return_status         => x_return_status,
                                            x_msg_count             => x_msg_count,
                                            x_msg_data              => x_msg_data);
  
  -->Update Organization
  vOrganization_rec.organization_name := p_cust_acct_rec_all.organization_name;
  vOrganization_rec.tax_reference := p_cust_acct_rec_all.tax_reference;
  vOrganization_rec.created_by_module := v_created_by_module;
  vOrganization_rec.application_id := v_application_id;
  
  vParty_rec.party_id := p_party_id;
  vOrganization_rec.party_rec := vParty_rec;
  
  HZ_PARTY_V2PUB.update_organization(p_init_msg_list               => p_init_msg_list,
                                     p_organization_rec            => vOrganization_rec,
                                     p_party_object_version_number => vObj_ver_num_org,
                                     x_profile_id                  => vProfile_id,
                                     x_return_status               => x_return_status,
                                     x_msg_count                   => x_msg_count,
                                     x_msg_data                    => x_msg_data);
  
End;
/*-------------------------------------------- 
   Update Customer Account
*/
Procedure update_cust_site_us
  (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_all                     IN     cust_acct_rec_upd_all_type,  
    p_cust_account_id                       IN    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is 
  vCust_site_use_rec HZ_CUST_ACCOUNT_SITE_V2PUB.cust_site_use_rec_type;
  vObject_Version_Number number;
  vErr                   varchar2(1000);
  vGl_Rec_Id             number;
  vGl_Rev_Id             number;
  vGl_Tax_Id             number;
  vLocation_Id           number;
begin
  -->Insert log
  FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Update Acc Site Use',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
  
  -->Truong hop update all tk
  if (p_cust_acct_rec_all.location_id_bill is null and p_cust_acct_rec_all.address1_bill is null
    and p_cust_acct_rec_all.address2_bill is null and p_cust_acct_rec_all.city_bill is null
    and p_cust_acct_rec_all.state_bill is null and p_cust_acct_rec_all.province_bill is null
    and p_cust_acct_rec_all.county_bill is null)then
    vLocation_Id := '';
  elsif p_cust_acct_rec_all.location_id_bill is not null then
    vLocation_Id := p_cust_acct_rec_all.location_id_bill;
  else
    vLocation_Id := -1;
  end if;
  
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Lay tk GL',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   -->Lay tai khoan Rec
   if p_cust_acct_rec_all.gl_rec is not null then
     vGl_Rec_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_rec, P_ERROR_MESSAGE => vErr);
     if vGl_Rec_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REC: ' || vErr;
       --RAISE FND_API.G_EXC_ERROR; 
       return;
     end if;
   end if;   
   -->Lay tai khoan Rev
   if p_cust_acct_rec_all.gl_rev is not null then
     vGl_Rev_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_rev, P_ERROR_MESSAGE => vErr);
     if vGl_Rev_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REV: ' || vErr;
       ---RAISE FND_API.G_EXC_ERROR; 
       return;
     end if;
   end if;
   -->Lay tai khoan Tax
   if p_cust_acct_rec_all.gl_tax is not null then
     vGl_Tax_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_rec_all.gl_tax, P_ERROR_MESSAGE => vErr);
     if vGl_Tax_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_TAX: ' || vErr;
       --RAISE FND_API.G_EXC_ERROR; 
       return;
     end if;
   end if;
  for i in(select hcsu.SITE_USE_ID, hcsu.Object_Version_Number,hcsu.CUST_ACCT_SITE_ID , hcsu.CREATED_BY_MODULE,hcsu.APPLICATION_ID
         from hz_cust_acct_sites_all hcas,
             HZ_CUST_SITE_USES_ALL hcsu,
              HZ_PARTY_SITES         hza
        where hcas.cust_acct_site_id = hcsu.CUST_ACCT_SITE_ID
          and hcas.party_site_id = hza.party_site_id
          and hcas.cust_account_id= p_cust_account_id
          and hcsu.Org_Id = p_cust_acct_rec_all.org_id
          and hcas.Org_Id = p_cust_acct_rec_all.org_id
          and hcsu.SITE_USE_CODE = 'BILL_TO'
          and (hza.LOCATION_ID = vLocation_Id or vLocation_Id is null)) loop
  
  vObject_Version_Number := i.Object_Version_Number;
  vCust_site_use_rec.site_use_id := i.SITE_USE_ID;
  vCust_site_use_rec.cust_acct_site_id := i.CUST_ACCT_SITE_ID;
  vCust_site_use_rec.created_by_module := i.created_by_module;
  vCust_site_use_rec.application_id := i.application_id;
  vCust_site_use_rec.gl_id_rec := vGl_Rec_Id;
  vCust_site_use_rec.gl_id_rev := vGl_Rev_Id;
  vCust_site_use_rec.gl_id_tax := vGl_Tax_Id;
  vCust_site_use_rec.org_id := p_cust_acct_rec_all.org_id;
  
  HZ_CUST_ACCOUNT_SITE_V2PUB.update_cust_site_use(p_init_msg_list         => p_init_msg_list,
                                                  p_cust_site_use_rec     => vCust_site_use_rec,
                                                  p_object_version_number => vObject_Version_Number,
                                                  x_return_status         => x_return_status,
                                                  x_msg_count             => x_msg_count,
                                                  x_msg_data              => x_msg_data);
  
  exit when x_return_status <> FND_API.G_RET_STS_SUCCESS;
  end loop;
  if x_return_status <> FND_API.G_RET_STS_SUCCESS then
    rollback;
    return;
  end if;  
end;

/*-------------------------------------------- 
   Update Customer Account all
*/
PROCEDURE update_customer_account (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_upd_all                 IN     cust_acct_rec_upd_all_type,
    x_bill_location_id                      OUT NOCOPY    NUMBER,
    x_ship_location_id                      OUT NOCOPY    NUMBER,   
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
)is
 vCheck_Acct       number := 1;
 vCheck_Tax        number :=0;
 vStatus           varchar2(1);
 vCust_account_id  number;
 vParty_id         number;
 vCust_Acc_site_Id number;
 vParty_Site_Id    number;
 vLocation_id      number;
Begin
    -->Insert log
    FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Begin',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   
    --> Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    
    -->Check Cust Number. If null then return
    if p_cust_acct_rec_upd_all.account_number is null then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'Customer number column is require.';
      return;
      --RAISE FND_API.G_EXC_ERROR;
    end if;
    
    -->Check Cust Number. If not exists then return
    begin
      select count(1), hca.status,hca.cust_account_id,hca.party_id 
        into vCheck_Acct,vStatus,vCust_account_id,vParty_id 
        from hz_cust_accounts hca
       where hca.account_number = p_cust_acct_rec_upd_all.account_number
       group by hca.status,hca.cust_account_id,hca.party_id ;
    exception
      when others then
        vCheck_Acct := 0;
        vStatus := 'I';
    end;
    
    if vCheck_Acct = 0 or vStatus = 'I' then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Customer does not exist or inactived.';
      return;
      --RAISE FND_API.G_EXC_ERROR;
    end if;
    
    -->Check tax_reference for cust. If exists then return
    if p_cust_acct_rec_upd_all.tax_reference is not null then
    select count(1) into vCheck_Tax from hz_parties hp, hz_cust_accounts hca
     where hp.tax_reference = p_cust_acct_rec_upd_all.tax_reference
       and hp.party_id = hca.party_id
       and hca.cust_account_id != vCust_account_id;
    if vCheck_Tax > 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Tax Number exist with another Customer!';
      return;
      --RAISE FND_API.G_EXC_ERROR;
    end if;
    end if;
    -->Lay thong tin profile id
    /*Begin
      select hcp.cust_account_profile_id into vCust_account_profile_id
        from AR.HZ_CUSTOMER_PROFILES hcp
       where hcp.cust_account_id = vCust_account_id
         and rownum = 1;
    Exception
      when others then
        
    End;*/
    
    -->Update Customer:   
    update_cust_account(p_init_msg_list      => p_init_msg_list,
                        p_cust_acct_rec_all  => p_cust_acct_rec_upd_all,  
                        p_cust_account_id    => vCust_account_id,
                        p_party_id           => vParty_id,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data);
    
    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      rollback;
      return;
    end if;
    
    -->If update cust status to 'I' (Inactive) then update only customer info
    if p_cust_acct_rec_upd_all.Acc_Status = 'I' then
      return;
    end if;
    
    -->Update location
    update_location(p_init_msg_list          => p_init_msg_list,
                    p_cust_acct_rec_upd_all  => p_cust_acct_rec_upd_all,      
                    x_location_id_b          => x_bill_location_id,
                    x_location_id_s          => x_ship_location_id,  
                    x_return_status          => x_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data);   
    
    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      rollback;
      return;
    end if;
    -->Kiem tra neu co location moi thi se tao theo Site
    if x_bill_location_id is not null or x_ship_location_id is not null then
       -->Lay thong tin Location
       vLocation_id := nvl(x_bill_location_id, x_ship_location_id);       
       
       -->Tao Party Site
       create_cust_party_site2(p_init_msg_list       => p_init_msg_list,
                          p_cust_acct_rec_all   => p_cust_acct_rec_upd_all,  
                          p_party_id            => vParty_Id,
                          p_location_id         => vLocation_Id,
                          x_party_site_id       => vParty_Site_Id,    
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data);
       
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         rollback;
         return;
       end if;
       -->Tao Customer Account Site
       create_cust_acc_site2(p_init_msg_list      => p_init_msg_list,
                            p_cust_acct_rec_all   => p_cust_acct_rec_upd_all, 
                            p_cust_account_id     => vCust_account_id,  
                            p_Party_Site_Id       => vParty_Site_Id,   
                            x_Cust_Acc_site_Id    => vCust_Acc_site_Id, 
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data);
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         rollback;
         return;
       end if;
       -->Tao Customer Account Site Use 
        -- l?y gi? tr? m? account_id n?u truy?n v?o cho tru?ng h?p g?n ship to v?i bill to
       
       
       
       create_cust_acc_site_use2(p_init_msg_list       => p_init_msg_list,
                                p_cust_acct_rec_all   => p_cust_acct_rec_upd_all, 
                                p_Cust_Acc_site_Id    => vCust_Acc_site_Id,  
                                p_Location_BILL_Id    => x_bill_location_id,   
                                p_Location_SHIP_Id    => x_ship_location_id,   
                                p_Profile_id          => 0,  
                                x_return_status       => x_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data);
         
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         rollback;
         return;
       end if;
    end if;   
   
   -->Update tai khoan
   if (p_cust_acct_rec_upd_all.gl_rec is not null or p_cust_acct_rec_upd_all.gl_rev is not null
       or p_cust_acct_rec_upd_all.gl_tax is not null) and p_cust_acct_rec_upd_all.country_bill is null then
     
    update_cust_site_us(p_init_msg_list      => p_init_msg_list,
                        p_cust_acct_rec_all  => p_cust_acct_rec_upd_all,  
                        p_cust_account_id    => vCust_account_id,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data);
   end if;
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   
   --> tru?ng h?p g?n site d? c? theo location_id 
   if (p_cust_acct_rec_upd_all.location_id_bill is not null or p_cust_acct_rec_upd_all.location_id_ship is not null)  and (p_cust_acct_rec_upd_all.country_bill is null and  p_cust_acct_rec_upd_all.country_ship is null)     
     then
		 vLocation_id := nvl(p_cust_acct_rec_upd_all.location_id_bill,p_cust_acct_rec_upd_all.location_id_ship);
      begin
    select hza.party_site_id into vParty_Site_Id
      from HZ_PARTY_SITES hza
     where hza.party_id = vParty_id
       and hza.location_id = vLocation_id
       and rownum = 1;
        exception
      when others then
         x_return_status := 'E';
         x_msg_count := 1;
         x_msg_data := 'Location_id is not valided!';
      end;  
         -->Tao Customer Account Site
       create_cust_acc_site2(p_init_msg_list      => p_init_msg_list,
                            p_cust_acct_rec_all   => p_cust_acct_rec_upd_all, 
                            p_cust_account_id     => vCust_account_id,  
                            p_Party_Site_Id       => vParty_Site_Id,   
                            x_Cust_Acc_site_Id    => vCust_Acc_site_Id, 
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data);
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         rollback;
         return;
       end if;
       -->Tao Customer Account Site Use 
       create_cust_acc_site_use2(p_init_msg_list       => p_init_msg_list,
                                p_cust_acct_rec_all   => p_cust_acct_rec_upd_all, 
                                p_Cust_Acc_site_Id    => vCust_Acc_site_Id,  
                                p_Location_BILL_Id    => p_cust_acct_rec_upd_all.location_id_bill,   
                                p_Location_SHIP_Id    => p_cust_acct_rec_upd_all.location_id_ship,   
                                p_Profile_id          => 0,  
                                x_return_status       => x_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data);
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         rollback;
         return;
       end if;
       end if;
    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   
   
   x_return_status := 'S';
   x_msg_count := 1;
   x_msg_data := 'Success !!!';
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','End',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null); 

/*EXCEPTION WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);*/ 
End;

----
  /* update customer: them moi dia chi cho all org*/
-----
PROCEDURE update_customer_account1 (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_rec_upd_all                 IN     cust_acct_rec_upd_all_type,
    x_bill_location_id                      OUT NOCOPY    NUMBER,
    x_ship_location_id                      OUT NOCOPY    NUMBER,   
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
)is
vcheck number;
 vCheck_Acct       number := 1;
 vCheck_Tax        number :=0;
 vStatus           varchar2(1);
 vCust_account_id  number;
 vParty_id         number;
 vCust_Acc_site_Id number;
 vParty_Site_Id    number;
 vLocation_id      number;
 v_org_id          number := p_cust_acct_rec_upd_all.org_id;
 v_cust_acct_rec_upd_all cust_acct_rec_upd_all_type := p_cust_acct_rec_upd_all;
Begin
    -->Insert log
    FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','Begin',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
    --- lay gia tri mac dinh 
     v_cust_acct_rec_upd_all.created_by_module := 'HZ_CPUI';
     v_cust_acct_rec_upd_all.application_id := '222';
    --> Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    
    -->Check Cust Number. If null then return
    if v_cust_acct_rec_upd_all.account_number is null then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'Customer number column is require.';
      return;
      --RAISE FND_API.G_EXC_ERROR;
    end if;
    
    -->Check Cust Number. If not exists then return
    begin
      select count(1), hca.status,hca.cust_account_id,hca.party_id 
        into vCheck_Acct,vStatus,vCust_account_id,vParty_id 
        from hz_cust_accounts hca
       where hca.account_number = v_cust_acct_rec_upd_all.account_number
       group by hca.status,hca.cust_account_id,hca.party_id ;
    exception
      when others then
        vCheck_Acct := 0;
        vStatus := 'I';
    end;
    
    if vCheck_Acct = 0 or vStatus = 'I' then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Customer does not exist or inactived.';
      return;
      --RAISE FND_API.G_EXC_ERROR;
    end if;
    
    -->Check tax_reference for cust. If exists then return
    if v_cust_acct_rec_upd_all.tax_reference is not null then
    select count(1) into vCheck_Tax from hz_parties hp, hz_cust_accounts hca
     where hp.tax_reference = v_cust_acct_rec_upd_all.tax_reference
       and hp.party_id = hca.party_id
       and hca.cust_account_id != vCust_account_id;
    if vCheck_Tax > 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Tax Number exist with another Customer!';
      return;
      --RAISE FND_API.G_EXC_ERROR;
    end if;
    end if;
    -->Lay thong tin profile id
    /*Begin
      select hcp.cust_account_profile_id into vCust_account_profile_id
        from AR.HZ_CUSTOMER_PROFILES hcp
       where hcp.cust_account_id = vCust_account_id
         and rownum = 1;
    Exception
      when others then
        
    End;*/
    
    -- Xử lý các truong hop cust có application_id null
    /*begin
      select count(1) into vcheck  from hz_cust_accounts hca
			where hca.account_number = v_cust_acct_rec_upd_all.account_number
      and (hca.application_id is null or hca.created_by_module is null);
       exception
		 when others then
			 null;
       if nvl(vcheck,0) = 0 then
         update hz_cust_accounts hca
         set hca.application_id = 222,
             hca.created_by_module = 'HZ_CPUI'
             where hca.account_number = v_cust_acct_rec_upd_all.account_number;
             commit;
         end if;
      end;*/
   
   
    -->Update Customer:   
    update_cust_account(p_init_msg_list      => p_init_msg_list,
                        p_cust_acct_rec_all  => v_cust_acct_rec_upd_all,  
                        p_cust_account_id    => vCust_account_id,
                        p_party_id           => vParty_id,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data);
    
    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      rollback;
      return;
    end if;
    
    -->If update cust status to 'I' (Inactive) then update only customer info
    if v_cust_acct_rec_upd_all.Acc_Status = 'I' then
      return;
    end if;
    
    -->Update location
    update_location(p_init_msg_list          => p_init_msg_list,
                    p_cust_acct_rec_upd_all  => v_cust_acct_rec_upd_all,      
                    x_location_id_b          => x_bill_location_id,
                    x_location_id_s          => x_ship_location_id,  
                    x_return_status          => x_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data);   
    
    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      rollback;
      return;
    end if;
    -->Kiem tra neu co location moi thi se tao theo Site
    if x_bill_location_id is not null or x_ship_location_id is not null then
       -->Lay thong tin Location
       vLocation_id := nvl(x_bill_location_id, x_ship_location_id);       
       
       -->Tao Party Site
       create_cust_party_site2(p_init_msg_list       => p_init_msg_list,
                          p_cust_acct_rec_all   => v_cust_acct_rec_upd_all,  
                          p_party_id            => vParty_Id,
                          p_location_id         => vLocation_Id,
                          x_party_site_id       => vParty_Site_Id,    
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data);
       
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         rollback;
         return;
       end if;
    for i in (select org_id, segment1, set_of_books_id, description 
                             from fpt_company_code_7_org 
                             where 1=1 and (org_id = v_org_id or v_org_id is null)
                             order by org_id) loop
     v_cust_acct_rec_upd_all.gl_rec := p_cust_acct_rec_upd_all.gl_rec;
     v_cust_acct_rec_upd_all.gl_rev := p_cust_acct_rec_upd_all.gl_rev;
     v_cust_acct_rec_upd_all.gl_tax := p_cust_acct_rec_upd_all.gl_tax;
     
     if v_cust_acct_rec_upd_all.gl_rec is not null then
     v_cust_acct_rec_upd_all.gl_rec := to_char(i.segment1 || substr(v_cust_acct_rec_upd_all.gl_rec,7));
     end if;
     if v_cust_acct_rec_upd_all.gl_rec is not null then
     v_cust_acct_rec_upd_all.gl_rev := to_char(i.segment1 || substr(v_cust_acct_rec_upd_all.gl_rev,7));
     end if;
     if v_cust_acct_rec_upd_all.gl_rec is not null then
     v_cust_acct_rec_upd_all.gl_tax := to_char(i.segment1 || substr(v_cust_acct_rec_upd_all.gl_tax,7));
     end if;
     
     vCust_Acc_site_Id :='';
     
       -->Tao Customer Account Site
       create_cust_acc_site2(p_init_msg_list      => p_init_msg_list,
                            p_cust_acct_rec_all   => v_cust_acct_rec_upd_all, 
                            p_org_id              => i.org_id,
                            p_cust_account_id     => vCust_account_id,  
                            p_Party_Site_Id       => vParty_Site_Id,   
                            x_Cust_Acc_site_Id    => vCust_Acc_site_Id, 
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data);
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         rollback;
         return;
       end if;
       -->Tao Customer Account Site Use 
        -- l?y gi? tr? m? account_id n?u truy?n v?o cho tru?ng h?p g?n ship to v?i bill to
       
       
       
       create_cust_acc_site_use2(p_init_msg_list       => p_init_msg_list,
                                p_cust_acct_rec_all   => v_cust_acct_rec_upd_all, 
                                p_org_id              => i.org_id,
                                p_Cust_Acc_site_Id    => vCust_Acc_site_Id,  
                                p_Location_BILL_Id    => x_bill_location_id,   
                                p_Location_SHIP_Id    => x_ship_location_id,   
                                p_Profile_id          => 0,  
                                x_return_status       => x_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data);
         
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         rollback;
         return;
       end if;
      end loop;
    end if;   
   
   -->Update tai khoan
   if (p_cust_acct_rec_upd_all.gl_rec is not null or p_cust_acct_rec_upd_all.gl_rev is not null
       or p_cust_acct_rec_upd_all.gl_tax is not null) and p_cust_acct_rec_upd_all.country_bill is null then
     
    update_cust_site_us(p_init_msg_list      => p_init_msg_list,
                        p_cust_acct_rec_all  => v_cust_acct_rec_upd_all,  
                        p_cust_account_id    => vCust_account_id,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data);
   end if;
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;
   
   --> tru?ng h?p g?n site d? c? theo location_id 
   /*if (p_cust_acct_rec_upd_all.location_id_bill is not null or p_cust_acct_rec_upd_all.location_id_ship is not null)  and (p_cust_acct_rec_upd_all.country_bill is null and  p_cust_acct_rec_upd_all.country_ship is null)     
     then
		 vLocation_id := nvl(p_cust_acct_rec_upd_all.location_id_bill,p_cust_acct_rec_upd_all.location_id_ship);
      begin
    select hza.party_site_id into vParty_Site_Id
      from HZ_PARTY_SITES hza
     where hza.party_id = vParty_id
       and hza.location_id = vLocation_id
       and rownum = 1;
        exception
      when others then
         x_return_status := 'E';
         x_msg_count := 1;
         x_msg_data := 'Location_id is not valided!';
      end;  
         -->Tao Customer Account Site
       create_cust_acc_site2(p_init_msg_list      => p_init_msg_list,
                            p_cust_acct_rec_all   => v_cust_acct_rec_upd_all, 
                            p_cust_account_id     => vCust_account_id,  
                            p_Party_Site_Id       => vParty_Site_Id,   
                            x_Cust_Acc_site_Id    => vCust_Acc_site_Id, 
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data);
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         rollback;
         return;
       end if;
       -->Tao Customer Account Site Use 
       create_cust_acc_site_use2(p_init_msg_list       => p_init_msg_list,
                                p_cust_acct_rec_all   => v_cust_acct_rec_upd_all, 
                                p_Cust_Acc_site_Id    => vCust_Acc_site_Id,  
                                p_Location_BILL_Id    => p_cust_acct_rec_upd_all.location_id_bill,   
                                p_Location_SHIP_Id    => p_cust_acct_rec_upd_all.location_id_ship,   
                                p_Profile_id          => 0,  
                                x_return_status       => x_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data);
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         rollback;
         return;
       end if;
       end if;*/
   /* if x_return_status <> FND_API.G_RET_STS_SUCCESS then
     rollback;
     return;
   end if;*/
   
   
   x_return_status := 'S';
   x_msg_count := 1;
   x_msg_data := 'Success !!!';
   -->Insert log
   FPT_DDP_SYN_PUB.erp_insert_table_log('AR','UPDATE CUSTOMER','End',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null); 


End;

PROCEDURE create_batch_cust_account_all (
    p_ddp_id                  in VARCHAR2,   
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_tbl_all       IN cust_acct_tbl_all_type,    
    p_cust_tbl_Type_out       OUT NOCOPY cust_tbl_Type_out, 
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    x_ddp_request_code        OUT NOCOPY VARCHAR2
) is


 vTab_index           NUMBER := p_cust_acct_tbl_all.FIRST;
 vCheck               boolean := true;
 vCheck2              number;
 vCustomer_id         number;
 vCustomer_type       varchar2(50);
 v_init_msg_list      varchar2(10) := p_init_msg_list;
 vCheck_Tax           number;
 vCheck_country_code  number;
 vErr                 varchar2(50);
 vGl_Rec_Id           number;
 vGl_Rev_Id           number;
 vGl_Tax_Id           number;
 v_ddp_id             number;
 v_cust_account_id    number;
 v_account_number     number;
 v_bill_location_id   number; 
 v_ship_location_id   number;
 v_ddp_request_code   varchar(50);
begin
  
  ---SAVEPOINT create_batch_cust_account_all;
  --x_ddp_request_code := p_ddp_request_code; -- return gia tri input
	x_return_status := fnd_api.g_ret_sts_success;
  --> check ddp_id in process
	begin
		select count(1)
			into vCheck2
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'Create_Customer'
			 and status = 'P';	
	end;   
   if nvl(vCheck2,0) >0 then
      x_return_status := 'PE';
      x_msg_count := 1;
      x_msg_data := 'The request with DDP_ID ' || p_ddp_id || ' is in processing!!!';
      return;
   end if;   
  ---> check ddp_id da chay thanh cong chua
  begin
    select count(1) 
      into vCheck2
      from FPT_DDP_CUSTOMER 
     where ddp_id = p_ddp_id;    
    end;
    if vCheck2 > 0 then
      for i in 1 .. p_cust_acct_tbl_all.COUNT LOOP 
				begin
					select ddp_request_code,
                 x_cust_account_id,
								 x_account_number,
								 x_bill_location_id,
								 x_ship_location_id
                 
						into v_ddp_request_code,
                 v_cust_account_id,
								 v_account_number,
								 v_bill_location_id,
								 v_ship_location_id
						from FPT_DDP_CUSTOMER
					 where ddp_id = p_ddp_id
						 and stt = i;
				exception
					when others then
						v_cust_account_id  := null;
						v_account_number   := null;
						v_bill_location_id := null;
						v_ship_location_id := null;
				end; 
        p_cust_tbl_Type_out(i).ddp_request_code :=  v_ddp_request_code;         
        p_cust_tbl_Type_out(i).x_cust_account_id := v_cust_account_id;
        p_cust_tbl_Type_out(i).x_account_number := v_account_number;
        p_cust_tbl_Type_out(i).x_bill_location_id := v_bill_location_id;
        p_cust_tbl_Type_out(i).x_ship_location_id := v_ship_location_id; 
        
     end loop;
     
     x_return_status := 'S';
     x_msg_count := 1;
      x_msg_data := 'Success !!!';
      return;
      
      end if;
      
  --> insert ddp_id
	insert into fpt_ddp_process
		(ddp_id, program, status)
	values
		(p_ddp_id, 'Create_Customer', 'P');
  commit;  
  --> check data input
  WHILE vTab_index <= p_cust_acct_tbl_all.LAST LOOP
 -->Check tax_reference for cust. If exists then return
    select count(1) into vCheck_Tax from hz_parties hp, hz_cust_accounts hca
     where hp.tax_reference = p_cust_acct_tbl_all(vTab_index).tax_reference
       and hp.party_id = hca.party_id;
    if vCheck_Tax > 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Customer (with this tax_reference) exists.';
      x_ddp_request_code := p_cust_acct_tbl_all(vTab_index).ddp_request_code;
      goto STOP;
     
    end if;
    --> check country code
    if p_cust_acct_tbl_all(vTab_index).country_bill is not null then
			select count(1)
				into vCheck_country_code
				from fnd_territories_tl
			 where territory_code = p_cust_acct_tbl_all(vTab_index).country_bill;  
     if nvl(vCheck_country_code,0) = 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Country Code of Bill to address is not correct !!!';
      x_ddp_request_code := p_cust_acct_tbl_all(vTab_index).ddp_request_code;
       goto STOP;
      
        end if;
    end if;
    
    if p_cust_acct_tbl_all(vTab_index).country_ship is not null then
			select count(1)
				into vCheck_country_code
				from fnd_territories_tl
			 where territory_code = p_cust_acct_tbl_all(vTab_index).country_ship;  
     if nvl(vCheck_country_code,0) = 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Country Code of Ship to address is not correct !!!';
      x_ddp_request_code := p_cust_acct_tbl_all(vTab_index).ddp_request_code;
       goto STOP;
      
        end if;
    end if;
    
    --> check TK input
    if p_cust_acct_tbl_all(vTab_index).gl_rec is not null then
     vGl_Rec_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_tbl_all(vTab_index).gl_rec, P_ERROR_MESSAGE => vErr);
     if vGl_Rec_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REC value ' || p_cust_acct_tbl_all(vTab_index).gl_rec || ' is not correct!';
       x_ddp_request_code := p_cust_acct_tbl_all(vTab_index).ddp_request_code;
        goto STOP;
      
     end if;
   end if;   
   -->Lay tai khoan Rev
   if p_cust_acct_tbl_all(vTab_index).gl_rev is not null then
     vGl_Rev_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_tbl_all(vTab_index).gl_rev, P_ERROR_MESSAGE => vErr);
     if vGl_Rev_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REV value ' || p_cust_acct_tbl_all(vTab_index).gl_rev || ' is not correct!';
       x_ddp_request_code := p_cust_acct_tbl_all(vTab_index).ddp_request_code;
        goto STOP;
     
     end if;
   end if;
   -->Lay tai khoan Tax
   if p_cust_acct_tbl_all(vTab_index).gl_tax is not null then
     vGl_Tax_Id := get_ccid_seg(P_ALL_SEGMENTS => p_cust_acct_tbl_all(vTab_index).gl_tax, P_ERROR_MESSAGE => vErr);
     if vGl_Tax_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_TAX value ' || p_cust_acct_tbl_all(vTab_index).gl_tax || ' is not correct!';
       x_ddp_request_code := p_cust_acct_tbl_all(vTab_index).ddp_request_code;
        goto STOP;
     
     end if;
   end if;
   ----
     <<STOP>>
      x_msg_data := 'Customer ' || p_cust_acct_tbl_all(vTab_index).account_name || ': ' || x_msg_data;
     	vTab_index := vTab_index + 1;
      exit when x_return_status = 'E';
   end loop;
   
    	--> return if any data check error     
	if (x_return_status <> fnd_api.g_ret_sts_success) then
    update fpt_ddp_process
       set Status = 'E'
     where ddp_id = p_ddp_id
       and program = 'Create_Customer'
       and Status = 'P';
    commit;
		return ;
	end if;
  --> insert customer
	vTab_index := p_cust_acct_tbl_all.FIRST;
  x_return_status := fnd_api.g_ret_sts_success;
  
	WHILE vTab_index <= p_cust_acct_tbl_all.LAST LOOP		
		begin
         create_customer_account_all1(
                        p_init_msg_list   => v_init_msg_list,
                        p_cust_acct_rec_all => p_cust_acct_tbl_all(vTab_index),
                        x_cust_account_id  => p_cust_tbl_Type_out(vTab_index).x_cust_account_id ,
                        x_account_number   => p_cust_tbl_Type_out(vTab_index).x_account_number,
                        x_bill_location_id  => p_cust_tbl_Type_out(vTab_index).x_bill_location_id,
                        x_ship_location_id => p_cust_tbl_Type_out(vTab_index).x_ship_location_id,   
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count   ,
                        x_msg_data           => x_msg_data   );
   p_cust_tbl_Type_out(vTab_index).ddp_request_code := p_cust_acct_tbl_all(vTab_index).ddp_request_code;
   if x_return_status = 'S' then
	 insert into FPT_DDP_CUSTOMER
		 (ddp_id,
			STT,
			x_cust_account_id,
			x_account_number,
			x_bill_location_id,
			x_ship_location_id,
			ddp_request_code)
	 values
		 (p_ddp_id,
			vTab_index,
			p_cust_tbl_Type_out(vTab_index).x_cust_account_id,
			p_cust_tbl_Type_out(vTab_index).x_account_number,
			p_cust_tbl_Type_out(vTab_index).x_bill_location_id,
			p_cust_tbl_Type_out(vTab_index).x_ship_location_id,
			p_cust_tbl_Type_out(vTab_index).ddp_request_code);  
   
   end if;
   end;
    	vTab_index := vTab_index + 1;
		exit when x_return_status != 'S';
   end loop;
 
   --> return if insert error
	if (x_return_status <> fnd_api.g_ret_sts_success) then
    rollback ;
    update fpt_ddp_process
       set Status = 'E'
     where ddp_id = p_ddp_id
       and program = 'Create_Customer'
       and Status = 'P';
    commit;
		return;
  end if;
  
   --> update trang thai ddp_id
   update fpt_ddp_process
      set Status = 'S'
    where ddp_id = p_ddp_id
      and program = 'Create_Customer'
      and Status = 'P';
   commit;
EXCEPTION WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);  
        update fpt_ddp_process
           set Status = 'E'
         where ddp_id = p_ddp_id
           and program = 'Create_Customer'
           and Status = 'P';
        commit;
                                  
end;

PROCEDURE update_customer_account_all (
    p_ddp_id                                in VARCHAR2,
   
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_tbl_upd_all                 IN     cust_acct_tbl_upd_all_type,    
    p_cust_tbl_upd_Type_out                 OUT NOCOPY    cust_tbl_upd_Type_out,
   
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2,
    x_ddp_request_code         OUT NOCOPY VARCHAR2
) is
 v_init_msg_list varchar2(20) := p_init_msg_list;
 vCheck_Acct       number := 1;
 vCheck_Tax        number :=0;
 vStatus           varchar2(1);
 vCust_account_id  number;
 vParty_id         number;
 vCust_Acc_site_Id number;
 vParty_Site_Id    number;
 vLocation_id      number;
 vTab_index NUMBER := p_cust_acct_tbl_upd_all.FIRST;
  vErr   varchar2(50);
 vGl_Rec_Id            number;
 vGl_Rev_Id            number;
 vGl_Tax_Id            number;
 v_ddp_id              number;
begin
  
  --SAVEPOINT update_customer_account_all;
 -- x_ddp_request_code := p_ddp_request_code; -- return gia tri input
  x_return_status := fnd_api.g_ret_sts_success;
   --> check ddp_id in process
	begin
		select count(1)
			into v_ddp_id
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'Update_Customer'
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
    --> check ddp_id in process
	begin
		select count(1)
			into v_ddp_id
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'Update_Customer'
			 and status = 'S';
	exception
		when others then
			v_ddp_id := null;
	end;   
   if nvl(v_ddp_id,0) >0 then
      x_return_status := 'S';
      x_msg_count := 1;
      x_msg_data := 'Update_Customer';
      return;
      end if;
  --> insert ddp_id
	insert into fpt_ddp_process
		(ddp_id, program, status, start_time)
	values
		(p_ddp_id, 'Update_Customer', 'P', sysdate);
    
  --> check data input
  WHILE vTab_index <= p_cust_acct_tbl_upd_all.LAST LOOP
       -->Check Cust Number. If null then return
    if p_cust_acct_tbl_upd_all(vTab_index).account_number is null then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'Customer number column is require.';
      x_msg_data := 'Customer ' || p_cust_acct_tbl_upd_all(vTab_index).account_number || ': ' || x_msg_data;
      x_ddp_request_code := p_cust_acct_tbl_upd_all(vTab_index).ddp_request_code;
    goto STOP1;
    end if;
    
    -->Check Cust Number. If not exists then return
    begin
      select count(1), hca.status,hca.cust_account_id,hca.party_id 
        into vCheck_Acct,vStatus,vCust_account_id,vParty_id 
        from hz_cust_accounts hca
       where hca.account_number = p_cust_acct_tbl_upd_all(vTab_index).account_number
       group by hca.status,hca.cust_account_id,hca.party_id ;
    exception
      when others then
        vCheck_Acct := 0;
        vStatus := 'I';
    end;
    
    if vCheck_Acct = 0 or vStatus = 'I' then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Customer does not exist or inactived.';
      x_msg_data := 'Customer ' || p_cust_acct_tbl_upd_all(vTab_index).account_number || ': ' || x_msg_data;
      x_ddp_request_code := p_cust_acct_tbl_upd_all(vTab_index).ddp_request_code;
      goto STOP1;
    end if;
    
    
    -->Check tax_reference for cust. If exists then return
    if p_cust_acct_tbl_upd_all(vTab_index).tax_reference is not null then
    select count(1) into vCheck_Tax from hz_parties hp, hz_cust_accounts hca
     where hp.tax_reference = p_cust_acct_tbl_upd_all(vTab_index).tax_reference
       and hp.party_id = hca.party_id
       and hca.cust_account_id != vCust_account_id;
     if vCheck_Tax > 0 then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'The Tax Number exist with another Customer!';
      x_msg_data := 'Customer ' || p_cust_acct_tbl_upd_all(vTab_index).account_number || ': ' || x_msg_data;
      x_ddp_request_code := p_cust_acct_tbl_upd_all(vTab_index).ddp_request_code;
      goto STOP1;
     end if;
    end if;
    
     --> check TK input
    if p_cust_acct_tbl_upd_all(vTab_index).gl_rec is not null then
     vGl_Rec_Id := get_ccid_seg1(P_ALL_SEGMENTS => p_cust_acct_tbl_upd_all(vTab_index).gl_rec, p_org_id => p_cust_acct_tbl_upd_all(vTab_index).org_id, P_ERROR_MESSAGE => vErr);
     if vGl_Rec_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REC value ' || p_cust_acct_tbl_upd_all(vTab_index).gl_rec || ' ' || 'is not correct!';
       x_msg_data := 'Customer ' || p_cust_acct_tbl_upd_all(vTab_index).account_number || ': ' || x_msg_data;
       x_ddp_request_code := p_cust_acct_tbl_upd_all(vTab_index).ddp_request_code;
        goto STOP1;
      elsif  vGl_Rec_Id = -2 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REC value ' || p_cust_acct_tbl_upd_all(vTab_index).gl_rec || ' ' || vErr;
       x_msg_data := 'Customer ' || p_cust_acct_tbl_upd_all(vTab_index).account_number || ': ' || x_msg_data;
       x_ddp_request_code := p_cust_acct_tbl_upd_all(vTab_index).ddp_request_code;
        goto STOP1;
     end if;
   end if;   
   -->Lay tai khoan Rev
   if p_cust_acct_tbl_upd_all(vTab_index).gl_rev is not null then
     vGl_Rev_Id := get_ccid_seg1(P_ALL_SEGMENTS => p_cust_acct_tbl_upd_all(vTab_index).gl_rev, p_org_id => p_cust_acct_tbl_upd_all(vTab_index).org_id, P_ERROR_MESSAGE => vErr);
     if vGl_Rev_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REV value ' || p_cust_acct_tbl_upd_all(vTab_index).gl_rev || ' ' || 'is not correct!';
       x_msg_data := 'Customer ' || p_cust_acct_tbl_upd_all(vTab_index).account_number || ': ' || x_msg_data;
       x_ddp_request_code := p_cust_acct_tbl_upd_all(vTab_index).ddp_request_code;
      goto STOP1;
      elsif  vGl_Rev_Id = -2 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_REV value ' || p_cust_acct_tbl_upd_all(vTab_index).gl_rev || ' ' || vErr;
       x_msg_data := 'Customer ' || p_cust_acct_tbl_upd_all(vTab_index).account_number || ': ' || x_msg_data;
       x_ddp_request_code := p_cust_acct_tbl_upd_all(vTab_index).ddp_request_code;
        goto STOP1;
     end if;
   end if;
   -->Lay tai khoan Tax
   if p_cust_acct_tbl_upd_all(vTab_index).gl_tax is not null then
     vGl_Tax_Id := get_ccid_seg1(P_ALL_SEGMENTS => p_cust_acct_tbl_upd_all(vTab_index).gl_tax, p_org_id => p_cust_acct_tbl_upd_all(vTab_index).org_id, P_ERROR_MESSAGE => vErr);
     if vGl_Tax_Id = -1 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_TAX value ' || p_cust_acct_tbl_upd_all(vTab_index).gl_tax ||  ' ' || 'is not correct!';
       x_msg_data := 'Customer ' || p_cust_acct_tbl_upd_all(vTab_index).account_number || ': ' || x_msg_data;
       x_ddp_request_code := p_cust_acct_tbl_upd_all(vTab_index).ddp_request_code;
       goto STOP1;
      elsif  vGl_Rev_Id = -2 then
       x_return_status := 'E';
       x_msg_count := 1;
       x_msg_data := 'GL_TAX value ' || p_cust_acct_tbl_upd_all(vTab_index).gl_tax || ' ' || vErr;
       x_msg_data := 'Customer ' || p_cust_acct_tbl_upd_all(vTab_index).account_number || ': ' || x_msg_data;
       x_ddp_request_code := p_cust_acct_tbl_upd_all(vTab_index).ddp_request_code;
        goto STOP1; 
     end if;
   end if;
   ----
      
      <<STOP1>>
     	vTab_index := vTab_index + 1;
      exit when x_return_status = 'E';
    end loop;
    
    	--> return if any data check error  
	if (x_return_status <> fnd_api.g_ret_sts_success) then
  --  rollback ;
		return;
	end if;
  --> call for each
    	vTab_index := p_cust_acct_tbl_upd_all.FIRST;
      x_return_status := fnd_api.g_ret_sts_success;
  
	WHILE vTab_index <= p_cust_acct_tbl_upd_all.LAST LOOP
		
		begin
         update_customer_account1(
                        p_init_msg_list   => v_init_msg_list,
                        p_cust_acct_rec_upd_all => p_cust_acct_tbl_upd_all(vTab_index),
                        x_bill_location_id  => p_cust_tbl_upd_Type_out(vTab_index).x_bill_location_id,
                        x_ship_location_id => p_cust_tbl_upd_Type_out(vTab_index).x_ship_location_id,   
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count   ,
                        x_msg_data           => x_msg_data   );
   
  p_cust_tbl_upd_Type_out(vTab_index).ddp_request_code := p_cust_acct_tbl_upd_all(vTab_index).ddp_request_code;
    
   end;
     
    	vTab_index := vTab_index + 1;
		exit when x_return_status != 'S';
   end loop;

   --> return if insert error
	if (x_return_status <> fnd_api.g_ret_sts_success) then
   -- rollback ;
		return;
	end if;

   --> update trang thai ddp_id
   update fpt_ddp_process
   set Status = 'S',
        end_time = sysdate
   where ddp_id = p_ddp_id
   and program = 'Update_Customer' ;
   
EXCEPTION WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);  
end;

END HZ_CUST_ACCOUNTS_V4PUB;
/
