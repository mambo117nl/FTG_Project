CREATE OR REPLACE PACKAGE HZ_CONTACT_PROJECT_V2PUB AUTHID CURRENT_USER AS
/*$Header: HZ_CONTACT_PROJECT_V2PUB.pls 120.1 2021/10/21 19:11:40 idali ship $ */
/*#
 * This package contains the public APIs for contacts and projects.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname  HZ_Contact Projects 
 * @rep:category BUSINESS_ENTITY FPT_PM_PROJECTS 
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Contact Project APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE project_rec_all_type IS RECORD (    
    
    ddp_request_code         VARCHAR2(50),
    Project_Code             VARCHAR2(100),    
    Project_name             VARCHAR2(255),    
    Project_Status           VARCHAR2(5), 
    START_DATE               VARCHAR2(10),
    Customer_number          VARCHAR2(50), 
    org_id                   number,
    ATTRIBUTE1               VARCHAR2(60),
    ATTRIBUTE2               VARCHAR2(60),
    ATTRIBUTE3               VARCHAR2(60),
    ATTRIBUTE4               VARCHAR2(60),
    ATTRIBUTE5               VARCHAR2(60)    
);

TYPE project_tbl_all_type IS TABLE OF project_rec_all_type INDEX BY BINARY_INTEGER;


TYPE project_Rec_Type_out IS RECORD
  (
   ddp_request_code         VARCHAR2(50),
   x_project_id           number,
   x_project_code        varchar2(100));
   
TYPE project_tbl_Type_out IS TABLE OF project_Rec_Type_out INDEX BY BINARY_INTEGER;

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------
/**
 * PROCEDURE create_contact_project
 *
 * DESCRIPTION
 *     Creates project.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:     
 *     p_project_rec_all            Customer account record. 
 *   IN/OUT:
 *   OUT:
 *     x_project_id                   Project ID.
 *     x_project_code                 Project code.      
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
 *   10-22-2021    BangTX      o Created.
 *
 */
/*#
 * Use this routine to create a customer account. The API creates records in the
 * DEV.FPT_PM_PROJECTS table. 
 * @param p_project_rec_all Project information. 
 * @param x_project_id Project ID.
 * @param x_project_code Project Code. 
 * @param x_return_status Return status after the call. The status can
 * be FND_API.G_RET_STS_SUCCESS (success),
 * FND_API.G_RET_STS_ERROR (error),
 * FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Message text if x_msg_count is 1.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project  (For Customer)
 * @rep:businessevent oracle.apps.ar.hz.Project.create
 * @rep:doccd 120hztig.pdf Project APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_contact_project (
    p_project_rec_all                       IN     project_rec_all_type,    
    x_project_id                            OUT NOCOPY    NUMBER,
    x_project_code                          OUT NOCOPY    VARCHAR2,     
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);



/**
 * PROCEDURE create_contact_project
 *
 * DESCRIPTION
 *     Creates project.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:     
 *     P_project_tbl_all_type            Customer account record. 
 *   IN/OUT:
 *   OUT:
 *     P_project_tbl_Type_out      
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
 *   10-22-2021    BangTX      o Created.
 *
 */
/*#
 * Use this routine to create a customer account. The API creates records in the
 * DEV.FPT_PM_PROJECTS table. 
 * @param P_DDP_ID ddp_id
 
 * @param P_project_tbl_all_type Project information. 
 * @param P_project_tbl_Type_out Project ID. 

 * @param x_return_status Return status after the call. The status can
 * be FND_API.G_RET_STS_SUCCESS (success),
 * FND_API.G_RET_STS_ERROR (error),
 * FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Message text if x_msg_count is 1.
 * @param x_ddp_request_code   ddp_request_code loi
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Batch Project  (For Customer)
 * @rep:businessevent oracle.apps.ar.hz.Project.create
 * @rep:doccd 120hztig.pdf Project APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
 
PROCEDURE create_batch_contact_project (
    P_DDP_ID                                   in VARCHAR2,
   
    P_project_tbl_all_type                       IN     project_tbl_all_type,    
    P_project_tbl_Type_out                       OUT NOCOPY    project_tbl_Type_out,
           
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2,
    x_ddp_request_code         OUT NOCOPY VARCHAR2
);


END HZ_CONTACT_PROJECT_V2PUB;
/
CREATE OR REPLACE PACKAGE BODY HZ_CONTACT_PROJECT_V2PUB AS
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
Procedure erp_insert_table_log(p_RESPONSE varchar2,p_REQEUST_NAME varchar2,p_DES varchar2,
                                 p_REQUEST_DATE date,p_START_DATE varchar2,END_DATE varchar2) is
    begin
      insert into FPT_REQUEST_LOG(ID,RESPONSE,REQEUST_NAME,DES,REQUEST_DATE,START_DATE,END_DATE)
        values(FPT_REQUEST_LOG_S.Nextval,p_RESPONSE,p_REQEUST_NAME,p_DES,p_REQUEST_DATE,p_START_DATE,END_DATE);
        commit;
    end;
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
/*-------------------------------------------- 
   Function check project information
*/
Function Check_Project(p_project_code varchar2, 
                       p_project_name varchar2, 
                       p_mess out varchar2) return boolean is
 vChk number;
Begin
  -->Project code/name is requiremanet
  if p_project_code is null or p_project_name is null then
    p_mess := 'Project code or name is requirement.';
    return false;
  end if;
  
  -->Check project code is exists or not
  select count(1) into vChk from DEV.FPT_PM_PROJECTS 
   where PROJECT_CODE = p_project_code;
   
  if vChk > 0 then
    p_mess := 'Project code is exists.';
    return false;
  end if; 
  
  return true;
End;

/*-------------------------------------------- 
   Function check Customer information
*/
Function Check_Customer(p_customer_number varchar2, 
                        p_org_id number,
                        p_Customer_id out number,
                        p_Customer_type out varchar2, 
                        p_mess out varchar2) return boolean is
 vChk number;
Begin
  -->If customer number is null then do not need to check
  if p_customer_number is null then
    return true;
  end if;
  
  -->Check project code is exists or not
  begin
    select count(1), hca.cust_account_id,hca.customer_type into vChk, p_Customer_id,p_Customer_type
      from hz_cust_accounts hca,hz_cust_acct_sites_all hcas,HZ_CUST_SITE_USES_ALL hcsu
     where hca.account_number = p_customer_number
       and hca.cust_account_id = hcas.cust_account_id
       and hcas.cust_acct_site_id = hcsu.cust_acct_site_id
       and hca.status = 'A'
       and hcsu.status = 'A'
       and hcsu.org_id = p_org_id
       and hcsu.site_use_code in ('BILL_TO','SHIP_TO')
     group by hca.cust_account_id,hca.customer_type;   
  exception 
    when others then
      vChk := 0;
  end;
  
  if vChk = 0 then
    p_mess := 'Customer is not exists or Inactived or dose not exists any Bill/Ship in this Org';
    return false;
  end if; 
  
  return true;
End;

/*-------------------------------------------- 
   Create Customer Account all
*/
PROCEDURE create_contact_project (    
    p_project_rec_all                       IN     project_rec_all_type,    
    x_project_id                            OUT NOCOPY    NUMBER,
    x_project_code                          OUT NOCOPY    VARCHAR2,     
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) is
 vCheck          boolean := true;
 vCustomer_id    number;
 vCustomer_type  varchar2(50);
 vData           DEV.FPT_PM_PROJECTS%rowtype;
 
Begin
   -->Insert log
   erp_insert_table_log('AR','CREATE PROJECT','Begin',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
   
   --> Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   
   -->Insert log
   erp_insert_table_log('AR','CREATE PROJECT','Check Project',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
    
   -->Check Project code, project name
   vCheck := Check_Project(p_project_rec_all.Project_Code, p_project_rec_all.Project_name, x_msg_data);
   if not vCheck then
     x_return_status := 'E';
     x_msg_count := 1;
     return;
   end if;
   
   -->Insert log
   erp_insert_table_log('AR','CREATE PROJECT','Check Customer',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);
    
   -->Check Customer Information
   vCheck := Check_Customer(p_project_rec_all.Customer_number, p_project_rec_all.org_id,vCustomer_id,vCustomer_type, x_msg_data);
   if not vCheck then
     x_return_status := 'E';
     x_msg_count := 1;
     return;
   end if;   
   
   -->Insert data into project table
   select DEV.FPT_PM_PROJECTS_S.NEXTVAL into x_project_id from dual;
   x_project_code := p_project_rec_all.Project_Code;
   vData.Project_Id := x_project_id;
   vData.Project_Code := p_project_rec_all.Project_Code;
   vData.Project_Name := p_project_rec_all.Project_name;
   vData.Start_Date := to_date(p_project_rec_all.START_DATE, 'DD-MM-YYYY');
   vData.Project_Status := nvl(p_project_rec_all.Project_Status, 'I');   
   if vCustomer_id is not null then
      vData.Customer_Id := vCustomer_id;
      vData.Customer_Type := 'C'/*vCustomer_type*/;
   end if;
   vData.Created_By := 0;
   vData.Creation_Date := sysdate;
   vData.Last_Updated_By := 0;
   vData.Last_Update_Date := sysdate;
   vData.Last_Update_Login := 0;
   vData.Description := 'DDP auto transfer';
   vData.Org_Id := p_project_rec_all.org_id;
   vData.Attribute1 := p_project_rec_all.ATTRIBUTE1;
   vData.Attribute2 := p_project_rec_all.ATTRIBUTE2;
   vData.Attribute3 := p_project_rec_all.ATTRIBUTE3;
   vData.Attribute4 := p_project_rec_all.ATTRIBUTE4;
   vData.Attribute5 := p_project_rec_all.ATTRIBUTE5;
   
   Insert into DEV.FPT_PM_PROJECTS(PROJECT_ID,
                                   PROJECT_NAME,
                                   PROJECT_CODE,
                                   PROJECT_STATUS,
                                   START_DATE,                                   
                                   CUSTOMER_ID,                                   
                                   DESCRIPTION,                                   
                                   ORG_ID,
                                   CREATION_DATE,
                                   CREATED_BY,
                                   LAST_UPDATE_DATE,
                                   LAST_UPDATED_BY,
                                   LAST_UPDATE_LOGIN,                                   
                                   CUSTOMER_TYPE,
                                   Attribute1,
                                   Attribute2,
                                   Attribute3,
                                   Attribute4,
                                   Attribute5)
                            values(vData.PROJECT_ID,
                                   vData.PROJECT_NAME,
                                   vData.PROJECT_CODE,
                                   vData.PROJECT_STATUS,
                                   vData.START_DATE,                                   
                                   vData.CUSTOMER_ID,                                   
                                   vData.DESCRIPTION,                                   
                                   vData.ORG_ID,
                                   vData.CREATION_DATE,
                                   vData.CREATED_BY,
                                   vData.LAST_UPDATE_DATE,
                                   vData.LAST_UPDATED_BY,
                                   vData.LAST_UPDATE_LOGIN,                                   
                                   vData.CUSTOMER_TYPE,
                                   vData.Attribute1,
                                   vData.Attribute2,
                                   vData.Attribute3,
                                   vData.Attribute4,
                                   vData.Attribute5);
   commit;
   
   x_msg_count := 0;
   x_msg_data := 'Successful!';
   -->Insert log
   erp_insert_table_log('AR','CREATE PROJECT','End',sysdate,to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'),null);       
  
EXCEPTION WHEN OTHERS THEN
        x_project_id := '';
        x_project_code := '';
        x_return_status := 'E'/*FND_API.G_RET_STS_UNEXP_ERROR*/;
        x_msg_count := 1;
        x_msg_data := sqlerrm;                                  
End;


PROCEDURE create_batch_contact_project (
    P_DDP_ID                                   in VARCHAR2,
   
    P_project_tbl_all_type                       IN     project_tbl_all_type,    
    P_project_tbl_Type_out                       OUT NOCOPY    project_tbl_Type_out,  
       
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2,
    x_ddp_request_code         OUT NOCOPY VARCHAR2
) IS

vTab_index NUMBER := P_project_tbl_all_type.FIRST;
vCheck          boolean := true;
 vCustomer_id    number;
 vCustomer_type  varchar2(50);

  v_ddp_id number;
 v_project_id number;
  v_project_code varchar2(200);
  v_ddp_request_code varchar(50);

begin
  	--> save point to rollback
	SAVEPOINT create_batch_contact_project;
 -- x_ddp_request_code := p_ddp_request_code; -- return gia tri input
	x_return_status := fnd_api.g_ret_sts_success;
  
   --> check ddp_id in process
	begin
		select count(1)
			into v_ddp_id
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'Create_Project'
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
		(p_ddp_id, 'Create_Project', 'P');
    
  --> check ddp_id da chay chua
  begin
    select count(1) 
    into v_ddp_id
    from FPT_CONTRACT_DDP 
     where ddp_id = p_ddp_id;
    exception when others then
      v_ddp_id := 0;
    end;
    if v_ddp_id > 0 then
      for i in 1 .. P_project_tbl_all_type.COUNT LOOP 
				begin
        select ddp_request_code,
               x_project_id,
							 x_project_code
					into v_ddp_request_code ,
               v_project_id,
							 v_project_code
				 from FPT_CONTRACT_DDP
         where ddp_id = p_ddp_id
					 and stt = i;        
        exception when others then
          v_project_id := null;
          v_project_code := null;
        end; 
        P_project_tbl_Type_out(i).ddp_request_code  := v_ddp_request_code;
        P_project_tbl_Type_out(i).x_project_id := v_project_id;
        P_project_tbl_Type_out(i).x_project_code := v_project_code;
        
        
        end loop;
     
     x_return_status := 'S';
     x_msg_count := 1;
      x_msg_data := 'Success !!!';
      return;
      
      end if;

	---> check data input before 
 WHILE vTab_index <= P_project_tbl_all_type.LAST LOOP
   -->Check Project code, project name
   vCheck := Check_Project(P_project_tbl_all_type(vTab_index).Project_Code, P_project_tbl_all_type(vTab_index).Project_name, x_msg_data);
   if not vCheck then
     x_return_status := 'E';
     x_msg_count := 1;
     
     goto STOP;
    -- return;
   end if;
    
   -->Check Customer Information
   vCheck := Check_Customer(P_project_tbl_all_type(vTab_index).Customer_number, P_project_tbl_all_type(vTab_index).org_id,vCustomer_id,vCustomer_type, x_msg_data);
   if not vCheck then
     x_return_status := 'E';
     x_msg_count := 1;
     goto STOP;
    -- return;
   end if;  
   
   <<STOP>>
   x_msg_data := 'Project ' || P_project_tbl_all_type(vTab_index).Project_Code || ': ' || x_msg_data;
   x_ddp_request_code := P_project_tbl_all_type(vTab_index).ddp_request_code;
    	vTab_index := vTab_index + 1;
		exit when x_return_status = 'E';
   end loop;
   
   	--> return if any data check error     
	if (x_return_status <> fnd_api.g_ret_sts_success) then
   	rollback;
		return;
	end if;

	--> insert Saleperson 
	vTab_index := P_project_tbl_all_type.FIRST;
  x_return_status := fnd_api.g_ret_sts_success;
  
	WHILE vTab_index <= P_project_tbl_all_type.LAST LOOP
		
		begin
      create_contact_project(p_project_rec_all  => P_project_tbl_all_type(vTab_index) ,    
                              x_project_id       => P_project_tbl_Type_out(vTab_index).x_project_id,
                              x_project_code     => P_project_tbl_Type_out(vTab_index).x_project_code,     
                              x_return_status    => x_return_status,
                              x_msg_count        => x_msg_count,
                              x_msg_data         => x_msg_data);
   P_project_tbl_Type_out(vTab_index).ddp_request_code := P_project_tbl_all_type(vTab_index).ddp_request_code;
    if x_return_status = 'S' then
	 insert into FPT_CONTRACT_DDP
		 (ddp_id, STT, x_project_id, x_project_code, ddp_request_code)
	 values
		 (p_ddp_id,
			vTab_index,
			P_project_tbl_Type_out(vTab_index).x_project_id,
			P_project_tbl_Type_out(vTab_index).x_project_code,
			P_project_tbl_Type_out(vTab_index).ddp_request_code);   
    end if;
    
    end;
    	vTab_index := vTab_index + 1;
		exit when x_return_status != 'S';
    end loop;
   
    --> return if insert error
	if (x_return_status <> fnd_api.g_ret_sts_success) then
		rollback ;
	   return;
	end if;
  
   --> update trang thai ddp_id
    update fpt_ddp_process
   set Status = 'S'
   where ddp_id = p_ddp_id
   and program = 'Create_Project' ;
   
   
EXCEPTION 
  WHEN OTHERS THEN
        
        x_return_status := 'E'/*FND_API.G_RET_STS_UNEXP_ERROR*/;
        x_msg_count := 1;
        x_msg_data := sqlerrm;        
end;

END HZ_CONTACT_PROJECT_V2PUB;
/
