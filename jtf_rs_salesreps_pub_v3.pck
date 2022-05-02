CREATE OR REPLACE PACKAGE JTF_RS_SALESREPS_PUB_V3  AS
/* $Header: jtfrspss3.pls 120.3 2005/07/19 18:56:53 repuri ship$ */
/*#
 * Salesperson create and update API
 * This API contains the procedures to insert and update Salesrep record.
 * @rep:scope public
 * @rep:product JTF
 * @rep:displayname Salespersons batch All API
 * @rep:category BUSINESS_ENTITY JTF_RS_SALESREP
 * @rep:category BUSINESS_ENTITY JTF_RS_ROLE_RELATION
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
*/
  /*****************************************************************************************
   This is a public API that caller will invoke. 
   It provides procedures for managing Salesreps, like
   create and update Salesreps from other modules.
   Its main procedures are as following:
   Create Salesreps bacth All
   ******************************************************************************************/


 TYPE Saleperson_Rec_Type IS RECORD (
   ddp_request_code         VARCHAR2(50),
   P_CATEGORY                JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,  
   START_DATE_ACTIVE        JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   END_DATE_ACTIVE           JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE   ,
   P_COMP_CURRENCY_CODE       JTF_RS_RESOURCE_EXTNS.Compensation_Currency_Code%TYPE ,
   P_COMMISSIONABLE_FLAG      JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE, 
   P_HOLD_PAYMENT             JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE ,  
   P_USER_ID                   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE ,          
   P_TRANSACTION_NUMBER        JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE ,
   P_RESOURCE_NAME             JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE ,
   P_ROLE_NAME                Jtf_Rs_Roles_Vl.ROLE_NAME%TYPE ,
   P_ROLE_TYPE_NAME           Jtf_Rs_Roles_Vl.ROLE_TYPE_CODE%TYPE ,
   R_START_DATE_ACTIVE      Jtf_Rs_Role_Relations.START_DATE_ACTIVE%TYPE ,
   R_END_DATE_ACTIVE        Jtf_Rs_Role_Relations.END_DATE_ACTIVE%TYPE    ,
   P_SALESREP_NUMBER         JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE   ,
   AR_START_DATE_ACTIVE      JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE  ,
   AR_END_DATE_ACTIVE      JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE   ,
   P_SOURCE_NAME              JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE,
   P_SOURCE_NUMBER           JTF_RS_RESOURCE_EXTNS.SOURCE_NUMBER%TYPE   ,  
   P_STATUS                  JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE  ,
   P_RESOURCE_ID           JTF_RS_SALESREPS.RESOURCE_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID  JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                   JTF_RS_SALESREPS.NAME%TYPE             ,
   P_GL_ID_REV              JTF_RS_SALESREPS.GL_ID_REV%TYPE      ,
   P_GL_ID_FREIGHT         JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE    ,
   P_GL_ID_REC              JTF_RS_SALESREPS.GL_ID_REC%TYPE    ,
   P_SET_OF_BOOKS_ID       JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE  ,
   P_EMAIL_ADDRESS         JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE ,
   P_WH_UPDATE_DATE        JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE ,
   P_SALES_TAX_GEOCODE     JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE  ,
   P_SALES_TAX_INSIDE_CITY_LIMITS    JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE ,
   P_ORG_ID                JTF_RS_SALESREPS.ORG_ID%TYPE 
  );
  
  
TYPE Saleperson_tbl_Type IS TABLE OF Saleperson_Rec_Type INDEX BY BINARY_INTEGER;


TYPE Saleperson_Rec_Type_out IS RECORD
  (
   ddp_request_code         VARCHAR2(50),
   X_RESOURCE_ID            JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER        JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   X_SALESREP_ID           JTF_RS_SALESREPS.SALESREP_ID%TYPE);
   
TYPE Saleperson_tbl_Type_out IS TABLE OF Saleperson_Rec_Type_out INDEX BY BINARY_INTEGER;


/* Procedure to create the batch Salesreps All 
  based on input values passed by calling routines. */
/*#
 * Create Salesreps batch All API   
 * This procedure allows the user to create a salesrep record.
 * @param p_DDP_ID batch ID.

 * @param p_api_version API version     
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit  
 * @param P_Saleperson_tbl_Type Saleperson record.
 
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
 * @param x_Saleperson_tbl_Type_out Saleperson record out.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create the Salesreps all API
 */ 
PROCEDURE  create_batch_salesrep_all
  (   p_DDP_ID                     IN   VARCHAR2,
     
      P_API_VERSION             IN   NUMBER,
      P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
      P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
      P_Saleperson_tbl_Type                  IN  Saleperson_tbl_Type,  
         
      x_return_status                  OUT NOCOPY    VARCHAR2,
      x_msg_count                      OUT NOCOPY    NUMBER,
      x_msg_data                       OUT NOCOPY    VARCHAR2,
      x_ddp_request_code         OUT NOCOPY VARCHAR2,
      x_Saleperson_tbl_Type_out              OUT NOCOPY    Saleperson_tbl_Type_out
  );
  

END JTF_RS_SALESREPS_PUB_V3;
/
CREATE OR REPLACE PACKAGE BODY JTF_RS_SALESREPS_PUB_V3  AS
/* $Header: jtfrspss1.pls 120.3 2005/07/19 18:56:53 repuri ship $ */

  

  /* Package variables. */

  G_PKG_NAME         CONSTANT VARCHAR2(30) := 'JTF_RS_SALESREPS_PUB_V3';
 -- G_PKG_NAME1         VARCHAR2(30) := 'JTF_RS_SALESREPS_PUB';

 PROCEDURE  create_salesrep_all
   (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_CATEGORY                IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,  
   START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.Compensation_Currency_Code%TYPE DEFAULT NULL,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE DEFAULT  'Y',
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE      DEFAULT  'N',
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE           DEFAULT  NULL,
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE DEFAULT  NULL,
   P_RESOURCE_NAME           IN   JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE  DEFAULT NULL,
   ---------roles relation
   P_ROLE_NAME              IN   Jtf_Rs_Roles_Vl.ROLE_NAME%TYPE DEFAULT NULL,
   P_ROLE_TYPE_NAME         IN   Jtf_Rs_Roles_Vl.ROLE_TYPE_CODE%TYPE DEFAULT NULL,
   R_START_DATE_ACTIVE    IN   Jtf_Rs_Role_Relations.START_DATE_ACTIVE%TYPE   DEFAULT SYSDATE,
   R_END_DATE_ACTIVE      IN   Jtf_Rs_Role_Relations.END_DATE_ACTIVE%TYPE     DEFAULT NULL,
   --------sales person
   P_SALESREP_NUMBER      IN   JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE     DEFAULT NULL,
   AR_START_DATE_ACTIVE    IN   JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE   DEFAULT SYSDATE,
   AR_END_DATE_ACTIVE      IN   JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE     DEFAULT NULL,
   P_SOURCE_NAME             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE,
   P_SOURCE_NUMBER           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NUMBER%TYPE     DEFAULT NULL,  
   P_STATUS                  IN   JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE     DEFAULT NULL,
   P_RESOURCE_ID          IN   JTF_RS_SALESREPS.RESOURCE_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID IN   JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                 IN   JTF_RS_SALESREPS.NAME%TYPE                DEFAULT NULL,
   P_GL_ID_REV            IN   JTF_RS_SALESREPS.GL_ID_REV%TYPE           DEFAULT NULL,
   P_GL_ID_FREIGHT        IN   JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE       DEFAULT NULL,
   P_GL_ID_REC            IN   JTF_RS_SALESREPS.GL_ID_REC%TYPE           DEFAULT NULL,
   P_SET_OF_BOOKS_ID      IN   JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE     DEFAULT NULL,
   P_EMAIL_ADDRESS        IN   JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE       DEFAULT NULL,
   P_WH_UPDATE_DATE       IN   JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE      DEFAULT NULL,
   P_SALES_TAX_GEOCODE    IN   JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE   DEFAULT NULL,
   P_SALES_TAX_INSIDE_CITY_LIMITS   IN   JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE   DEFAULT NULL,
   P_ORG_ID                  IN   JTF_RS_SALESREPS.ORG_ID%TYPE              DEFAULT FND_API.G_MISS_NUM,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER         OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   X_SALESREP_ID    	       OUT NOCOPY  JTF_RS_SALESREPS.SALESREP_ID%TYPE
  ) IS
  
  
  
 cursor c_validate_salesper_number(v_salesrep_number  in jtf_rs_salesreps.salesrep_number%type)is
  select 1
    from jtf_rs_salesreps
   where salesrep_number = v_salesrep_number;
  
  r_validate_salesper_number c_validate_salesper_number%rowtype;
  
 cursor c_role_id(role_name varchar2, role_type_name varchar2) is
  select t.role_id from jtf_rs_roles_vl t
   where t.role_name = role_name
     and t.role_type_code = role_type_name
     and rownum = 1;
  r_role_id c_role_id%rowtype;
  
  l_start_date_active    jtf_rs_resource_extns.start_date_active%type   := start_date_active;
  l_end_date_active      jtf_rs_resource_extns.start_date_active%type   := end_date_active;
  
   l_api_version             number := 1;
   l_init_msg_list           varchar2(20) := p_init_msg_list;
   l_commit                  varchar2(20) :=  p_commit  ;
   l_api_name                CONSTANT VARCHAR2(30) := 'CREATE_SALESREP_ALL';
   l_category                jtf_rs_resource_extns.category%type := nvl(p_category,'OTHER');  
   l_coml_currency_code      jtf_rs_resource_extns.compensation_currency_code%type := P_COMP_CURRENCY_CODE;
   l_commissionable_flag     jtf_rs_resource_extns.commissionable_flag%type := p_commissionable_flag;
   l_hold_payment            jtf_rs_resource_extns.hold_payment%type  := p_hold_payment;
   l_resource_name           jtf_rs_resource_extns_tl.resource_name%type  := p_resource_name;
   l_source_name             jtf_rs_resource_extns.source_name%type := p_source_name;
   l_source_number           jtf_rs_resource_extns.source_number%type  := p_source_number ;
   l_salesrep_number         jtf_rs_salesreps.salesrep_number%type  := p_salesrep_number;   
   l_role_name               jtf_rs_roles_vl.role_name%type := nvl(p_role_name,'Sales Representative');
   l_role_type_name          jtf_rs_roles_vl.role_type_code%type := nvl(p_role_type_name,'SALES');
   l_org_id                  jtf_rs_salesreps.org_id%type  := p_org_id;
   l_set_of_books_id         jtf_rs_salesreps.set_of_books_id%type  := p_set_of_books_id;
   v_resource_id             number ;
   v_resource_number         number ;
   v_role_related_id         number;
   v_role_id                 number;
   v_salesrep_id    	       jtf_rs_salesreps.salesrep_id%type  := x_salesrep_id ;
   n                         number := 0;
  begin
    --> save point to rollback
     SAVEPOINT create_salesreps_pub_v1;

    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;
   
  --> Create resource 
  begin
       jtf_rs_resource_pub.create_resource(P_API_VERSION => l_api_version,
                                           P_INIT_MSG_LIST => p_init_msg_list,
                                           P_COMMIT => 'T',
                                           P_CATEGORY => l_category,
                                           P_START_DATE_ACTIVE => l_start_date_active,
                                           P_END_DATE_ACTIVE => l_end_date_active,
                                           P_COMP_CURRENCY_CODE => l_coml_currency_code,
                                           P_COMMISSIONABLE_FLAG => l_commissionable_flag,
                                           P_HOLD_PAYMENT => l_hold_payment,
                                           P_RESOURCE_NAME => l_resource_name,
                                           P_SOURCE_NAME => l_source_name,
                                           P_SOURCE_NUMBER => l_source_number,
                                           X_RETURN_STATUS => X_RETURN_STATUS,
                                           X_MSG_COUNT => X_MSG_COUNT,
                                           X_MSG_DATA => X_MSG_DATA,
                                           X_RESOURCE_ID => v_resource_id,
                                           X_RESOURCE_NUMBER => v_resource_number
                                           );
    
    end;
    if (x_return_status <> fnd_api.g_ret_sts_success)  then
      rollback to create_salesreps_pub_v1;
      return;
      end if;
      
  x_resource_id := v_resource_id;
  x_resource_number := v_resource_number;
  
  --> create role realation
  Open c_role_id(l_role_name,l_role_type_name);
  loop
   Fetch c_role_id
      into v_role_id;    
     exit when c_role_id%notfound;
       end loop;
        close c_role_id;
   if v_resource_id is not null then
     l_start_date_active := nvl(R_START_DATE_ACTIVE,l_start_date_active);
     l_end_date_active  := nvl(R_END_DATE_ACTIVE,l_end_date_active);
     begin
       jtf_rs_role_relate_pub.create_resource_role_relate( p_api_version         => l_api_version ,
                                                           p_init_msg_list       => l_init_msg_list,
                                                           p_commit              => l_commit,
                                                           p_role_resource_type  => to_char('RS_INDIVIDUAL'),
                                                           p_role_resource_id    => v_resource_id,
                                                           p_role_id             =>  32,
                                                           p_role_code           => 'SALES',
                                                           p_start_date_active   => l_start_date_active,
                                                           p_end_date_active     => l_end_date_active,
                                                           x_return_status       => x_return_status,
                                                           x_msg_count           => x_msg_count,
                                                           x_msg_data            => x_msg_data,
                                                           x_role_relate_id    =>  v_role_related_id);
     
    
       end;
       if (x_return_status <> fnd_api.g_ret_sts_success)  then
              rollback to create_salesreps_pub_v1;
              x_msg_count := 1;
              x_msg_data := 'Role realation is not success !!!';
                return;
            end if;
     end if;
  
  
  
  --> create to 1 org
    if l_org_id is not null then
        begin
             jtf_rs_salesreps_pub.create_salesrep(   P_API_VERSION => l_api_version,
                                                     p_init_msg_list        => l_init_msg_list,
                                                     p_commit               =>  l_commit,
                                                     p_resource_id          => v_resource_id,
                                                     p_sales_credit_type_id => 1,
                                                     p_name                 => l_source_name,
                                                     p_status               => 'A',
                                                     p_start_date_active    => l_start_date_active,
                                                     p_end_date_active      => l_end_date_active,
                                                     p_org_id               => l_org_id,
                                                     p_gl_id_rev            => '',
                                                     p_gl_id_freight        =>  '',
                                                     p_gl_id_rec            =>  '',
                                                     p_set_of_books_id      => '',-- l_set_of_books_id,
                                                     p_salesrep_number      =>  l_salesrep_number,
                                                     p_sales_tax_inside_city_limits => 'Y',
                                                     x_return_status       =>  x_return_status,
                                                     x_msg_count           =>  x_msg_count,
                                                     x_msg_data            =>  x_msg_data,
                                                     X_SALESREP_ID    	 => v_salesrep_id );
    X_SALESREP_ID :=    v_salesrep_id;
     exception when
          others then
              x_return_status := 'E';
              x_msg_count := 1;
              x_msg_data := 'T?o sales person kh�ng th�nh c�ng!!!';
                return;
         end;
         end if;
         if (x_return_status = fnd_api.g_ret_sts_success) and  v_salesrep_id is not null then 
              x_msg_count := 0;
              x_msg_data := 'T?o sales person th�nh c�ng!!!';
           end if;
           
  --> create sales person to all
  if l_org_id is null then
     l_start_date_active := nvl(ar_start_date_active,l_start_date_active);
     l_end_date_active  := nvl(ar_end_date_active,l_end_date_active);
  for i in (select org_id, set_of_books_id, description from fpt_company_code_7_org order by org_id) loop
         
   begin
             jtf_rs_salesreps_pub.create_salesrep(   P_API_VERSION => l_api_version,
                                                     p_init_msg_list        => l_init_msg_list,
                                                     p_commit               =>  l_commit,
                                                     p_resource_id          => v_resource_id,
                                                     p_sales_credit_type_id => 1,
                                                     p_name                 => l_source_name,
                                                     p_status               => 'A',
                                                     p_start_date_active    => l_start_date_active,
                                                     p_end_date_active      => l_end_date_active,
                                                     p_org_id               => i.org_id,
                                                     p_gl_id_rev            => '',
                                                     p_gl_id_freight        =>  '',
                                                     p_gl_id_rec            =>  '',
                                                     p_set_of_books_id      =>  i.set_of_books_id,
                                                     p_salesrep_number      =>  l_salesrep_number,
                                                     p_sales_tax_inside_city_limits => 'Y',
                                                     x_return_status       =>  x_return_status,
                                                     x_msg_count           =>  x_msg_count,
                                                     x_msg_data            =>  x_msg_data,
                                                     X_SALESREP_ID    	 => v_salesrep_id );
          end;
          n := n + 1;
       /*   v_salesrep_id := i.org_id || '-' || v_salesrep_id;
      X_SALESREP_ID := X_SALESREP_ID || ', ' ||  v_salesrep_id;*/
   X_SALESREP_ID :=  v_salesrep_id;
   
    --exit when  x_return_status != 'S';
   end loop;
  end if;
 if (x_return_status <> fnd_api.g_ret_sts_success)  then
              rollback to create_salesreps_pub_v1;
              x_msg_count := 1;
              x_msg_data := 'Error to create sales person!';
                return;
            else
               x_msg_data := 'Success !!!';
            end if;

   EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_salesreps_pub_v1;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_salesreps_pub_v1;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_salesreps_pub_v1;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
 
 
 end create_salesrep_all;


PROCEDURE create_batch_salesrep_all(p_DDP_ID                  IN VARCHAR2,                                    
                                    P_API_VERSION             IN NUMBER,
																		P_INIT_MSG_LIST           IN VARCHAR2 DEFAULT FND_API.G_FALSE,
																		P_COMMIT                  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
																		P_Saleperson_tbl_Type     IN Saleperson_tbl_Type,                                    
																		x_return_status           OUT NOCOPY VARCHAR2,
																		x_msg_count               OUT NOCOPY NUMBER,
																		x_msg_data                OUT NOCOPY VARCHAR2,
                                    x_ddp_request_code        OUT NOCOPY VARCHAR2,
																		x_Saleperson_tbl_Type_out OUT NOCOPY Saleperson_tbl_Type_out) IS

	cursor c_validate_salesper_number(v_salesrep_number in jtf_rs_salesreps.salesrep_number%type) is
		select 1
			from jtf_rs_salesreps
		 where salesrep_number = v_salesrep_number;
	r_validate_salesper_number c_validate_salesper_number%rowtype;
  
	l_api_version   NUMBER := 1;
	v_INIT_MSG_LIST VARCHAR2(10) := 'T';
	v_COMMIT        VARCHAR2(10) := 'T';
	l_api_name CONSTANT VARCHAR2(30) := 'JTF_RS_SALESREPS_PUB_V3';
  vUser_name   VARCHAR2(30) := 'FES_SOA';
  vResp_name   VARCHAR2(30) := 'Development Manager';
	vTab_index NUMBER := P_Saleperson_tbl_Type.FIRST;
  v_P_SALESREP_NUMBER_tbl sys.odcinumberlist;
  v_number number :=0;
  v_salesrep_number   VARCHAR2(30);
   v_ddp_id number;
 v_resource_id number;
  v_salesrep_id number;
  v_resource_number varchar2(100);
  v_ddp_request_code varchar(50);
Begin
	--> save point to rollback
	SAVEPOINT create_batch_salesrep_all;
  --x_ddp_request_code := p_ddp_request_code; -- return gia tri input
	x_return_status := fnd_api.g_ret_sts_success;
  --> check ddp_id in process
  begin
		select count(1)
			into v_ddp_id
			from fpt_ddp_process
		 where ddp_id = p_ddp_id
			 and program = 'Create_Saleperson'
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
		(ddp_id, program, status,start_time)
	values
		(p_ddp_id, 'Create_Saleperson', 'P', sysdate);
    
  --> check ddp_id da chay chua tu bang luu
  begin
    select count(1) 
    into v_ddp_id
    from FPT_DDP_SALESPESON
     where ddp_id = p_ddp_id;
    exception when others then
      v_ddp_id := 0;
    end;
    if v_ddp_id > 0  then
      for i in 1 .. P_Saleperson_tbl_Type.COUNT LOOP 
				begin
					select ddp_request_code,
                 X_RESOURCE_ID, 
                 X_RESOURCE_NUMBER, 
                 X_SALESREP_ID
						into v_ddp_request_code,
                 v_resource_id, 
                 v_resource_number, 
                 v_salesrep_id
						from FPT_DDP_SALESPESON
					 where ddp_id = p_ddp_id
						 and stt = i;
				exception
					when others then
            v_ddp_request_code := null;
						v_resource_id     := null;
						v_resource_number := null;
						v_salesrep_id     := null;
				end; 
        x_Saleperson_tbl_Type_out(i).ddp_request_code :=  v_ddp_request_code;    
        x_Saleperson_tbl_Type_out(i).X_RESOURCE_ID := v_resource_id;
        x_Saleperson_tbl_Type_out(i).X_RESOURCE_NUMBER := v_resource_number;
        x_Saleperson_tbl_Type_out(i).X_SALESREP_ID := v_salesrep_id;
        
        end loop;
     
     x_return_status := 'S';
     x_msg_count := 1;
      x_msg_data := 'Success !!!';
      return;
      
      end if;

/*  --> check trung Saleperson number input
  for i in 1 .. P_Saleperson_tbl_Type.count loop
   v_salesrep_number    := P_Saleperson_tbl_Type(i).p_salesrep_number;
			insert into Fpt_Salespeson_number(Ddp_Id,Salesperson_Number,Status)
			values (p_DDP_ID,v_salesrep_number,'I');      
   
    end loop;
		begin
			select max(count(Salesperson_Number))
				into v_number
				from Fpt_Salespeson_number
			 where Ddp_Id = p_DDP_ID
				 and status = 'I'
			 group by Salesperson_Number;		
       exception
			when others then
				v_number := 0;
		end;   
     if v_number > 1 then 
      delete Fpt_Salespeson_number where Ddp_Id = p_DDP_ID;
				x_return_status := 'E';
				x_msg_count     := 1;
				x_msg_data      := 'Error: There are more than 2 Saleperson Number Input !!!';
			 return;
			else
         update Fpt_Salespeson_number t
          set t.status = 'P'
          where t.ddp_id = p_DDP_ID;
      end if;*/
      
      ---> check data input
	WHILE vTab_index <= P_Saleperson_tbl_Type.LAST LOOP
		---> check salesrep_number c� b? tr�ng tr�n h? th?ng kh�ng
		declare
			l_salesrep_number      jtf_rs_salesreps.salesrep_number%type := P_Saleperson_tbl_Type(vTab_index)
																																			.p_salesrep_number;
			l_category             jtf_rs_resource_extns.category%type := nvl(P_Saleperson_tbl_Type(vTab_index)
																																				.p_category,
																																				'OTHER');
			l_start_date_active    jtf_rs_resource_extns.start_date_active%type := P_Saleperson_tbl_Type(vTab_index)
																																						 .start_date_active;
			l_end_date_active      jtf_rs_resource_extns.start_date_active%type := P_Saleperson_tbl_Type(vTab_index)
																																						 .end_date_active;
			l_AR_START_DATE_ACTIVE date := P_Saleperson_tbl_Type(vTab_index)
																		 .AR_START_DATE_ACTIVE;
			l_R_START_DATE_ACTIVE  date := P_Saleperson_tbl_Type(vTab_index)
																		 .R_START_DATE_ACTIVE;
		begin
			if l_salesrep_number is not null then
				OPEN c_validate_salesper_number(l_salesrep_number);
				FETCH c_validate_salesper_number
					INTO r_validate_salesper_number;
				if c_validate_salesper_number%found then
					x_return_status := 'E';
					x_msg_count     := 1;
					x_msg_data      := 'Salesreps_number already exsits!!!';
          x_ddp_request_code := P_Saleperson_tbl_Type(vTab_index).ddp_request_code;
					-- Return;
				end if;
				CLOSE c_validate_salesper_number;
			end if;
		
			--> tru?ng h?p category kh�c OTHER kh�ng ti?p t?c
			if l_category != 'OTHER' then
				x_return_status := 'E';
				x_msg_count     := 1;
				x_msg_data      := x_msg_data || '-' ||
													 'Category  is not valid, it must be Other !!!';
        x_ddp_request_code := P_Saleperson_tbl_Type(vTab_index).ddp_request_code;
				-- return;
			end if;
		
			--> tru?ng h?p ng�y active sales person nh? hon ng�y active c?a resource
			if nvl(l_AR_START_DATE_ACTIVE, l_start_date_active) <
				 l_start_date_active or
				 nvl(l_R_START_DATE_ACTIVE, l_start_date_active) <
				 l_start_date_active then
				x_return_status := 'E';
				x_msg_count     := 1;
				x_msg_data      := x_msg_data || '-' ||
													 'START_DATE_ACTIVE of  sales person must be greater than  START_DATE_ACTIVE of resource !!!';
        x_ddp_request_code := P_Saleperson_tbl_Type(vTab_index).ddp_request_code;
				--return;
			end if;
		end;
    if x_return_status = 'E' then
      x_msg_count     := 1;
		x_msg_data := 'Saleperson ' || P_Saleperson_tbl_Type(vTab_index).p_salesrep_number || ' error: ' ||	x_msg_data;
     x_ddp_request_code := P_Saleperson_tbl_Type(vTab_index).ddp_request_code;
     end if;
		vTab_index := vTab_index + 1;
		exit when x_return_status = 'E';
	end loop;
	--> return if any data check error     
	if (x_return_status <> fnd_api.g_ret_sts_success) then
   		rollback to create_batch_salesrep_all;
		return;
	end if;

	--> insert Saleperson 
	vTab_index := P_Saleperson_tbl_Type.FIRST;
  x_return_status := fnd_api.g_ret_sts_success;
  
	WHILE vTab_index <= P_Saleperson_tbl_Type.LAST LOOP
		
		begin
		
			--> run for each 
			JTF_RS_SALESREPS_PUB_V2.create_salesrep_all(P_API_VERSION                  => l_api_version,
													P_INIT_MSG_LIST                => v_INIT_MSG_LIST,
													P_COMMIT                       => v_COMMIT,
													P_CATEGORY                     => P_Saleperson_tbl_Type(vTab_index)
																														.P_CATEGORY,
													START_DATE_ACTIVE              => P_Saleperson_tbl_Type(vTab_index)
																														.START_DATE_ACTIVE,
													END_DATE_ACTIVE                => P_Saleperson_tbl_Type(vTab_index)
																														.END_DATE_ACTIVE,
													P_COMP_CURRENCY_CODE           => P_Saleperson_tbl_Type(vTab_index)
																														.P_COMP_CURRENCY_CODE,
													P_COMMISSIONABLE_FLAG          => P_Saleperson_tbl_Type(vTab_index)
																														.P_COMMISSIONABLE_FLAG,
													P_HOLD_PAYMENT                 => P_Saleperson_tbl_Type(vTab_index)
																														.P_HOLD_PAYMENT,
													P_USER_ID                      => P_Saleperson_tbl_Type(vTab_index)
																														.P_USER_ID,
													P_TRANSACTION_NUMBER           => P_Saleperson_tbl_Type(vTab_index)
																														.P_TRANSACTION_NUMBER,
													P_RESOURCE_NAME                => P_Saleperson_tbl_Type(vTab_index)
																														.P_RESOURCE_NAME,
													P_ROLE_NAME                    => P_Saleperson_tbl_Type(vTab_index)
																														.P_ROLE_NAME,
													P_ROLE_TYPE_NAME               => P_Saleperson_tbl_Type(vTab_index)
																														.P_ROLE_TYPE_NAME,
													R_START_DATE_ACTIVE            => P_Saleperson_tbl_Type(vTab_index)
																														.R_START_DATE_ACTIVE,
													R_END_DATE_ACTIVE              => P_Saleperson_tbl_Type(vTab_index)
																														.R_END_DATE_ACTIVE,
													P_SALESREP_NUMBER              => P_Saleperson_tbl_Type(vTab_index)
																														.P_SALESREP_NUMBER,
													AR_START_DATE_ACTIVE           => P_Saleperson_tbl_Type(vTab_index)
																														.AR_START_DATE_ACTIVE,
													AR_END_DATE_ACTIVE             => P_Saleperson_tbl_Type(vTab_index)
																														.AR_END_DATE_ACTIVE,
													P_SOURCE_NAME                  => P_Saleperson_tbl_Type(vTab_index)
																														.P_SOURCE_NAME,
													P_SOURCE_NUMBER                => P_Saleperson_tbl_Type(vTab_index)
																														.P_SOURCE_NUMBER,
													P_STATUS                       => P_Saleperson_tbl_Type(vTab_index)
																														.P_STATUS,
													P_RESOURCE_ID                  => P_Saleperson_tbl_Type(vTab_index)
																														.P_RESOURCE_ID,
													P_SALES_CREDIT_TYPE_ID         => P_Saleperson_tbl_Type(vTab_index)
																														.P_SALES_CREDIT_TYPE_ID,
													P_NAME                         => P_Saleperson_tbl_Type(vTab_index)
																														.P_NAME,
													P_GL_ID_REV                    => P_Saleperson_tbl_Type(vTab_index)
																														.P_GL_ID_REV,
													P_GL_ID_FREIGHT                => P_Saleperson_tbl_Type(vTab_index)
																														.P_GL_ID_FREIGHT,
													P_GL_ID_REC                    => P_Saleperson_tbl_Type(vTab_index)
																														.P_GL_ID_REC,
													P_SET_OF_BOOKS_ID              => P_Saleperson_tbl_Type(vTab_index)
																														.P_SET_OF_BOOKS_ID,
													P_EMAIL_ADDRESS                => P_Saleperson_tbl_Type(vTab_index)
																														.P_EMAIL_ADDRESS,
													P_WH_UPDATE_DATE               => P_Saleperson_tbl_Type(vTab_index)
																														.P_WH_UPDATE_DATE,
													P_SALES_TAX_GEOCODE            => P_Saleperson_tbl_Type(vTab_index)
																														.P_SALES_TAX_GEOCODE,
													P_SALES_TAX_INSIDE_CITY_LIMITS => P_Saleperson_tbl_Type(vTab_index)
																														.P_SALES_TAX_INSIDE_CITY_LIMITS,
													P_ORG_ID                       => P_Saleperson_tbl_Type(vTab_index)
																														.P_ORG_ID,
													X_RETURN_STATUS                => x_return_status,
													X_MSG_COUNT                    => X_MSG_COUNT,
													X_MSG_DATA                     => x_msg_data,
													X_RESOURCE_ID                  => x_Saleperson_tbl_Type_out(vTab_index)
																														.X_RESOURCE_ID,
													X_RESOURCE_NUMBER              => x_Saleperson_tbl_Type_out(vTab_index)
																														.X_RESOURCE_NUMBER,
													X_SALESREP_ID                  => x_Saleperson_tbl_Type_out(vTab_index)
																														.X_SALESREP_ID);
		
    x_Saleperson_tbl_Type_out(vTab_index).ddp_request_code := P_Saleperson_tbl_Type(vTab_index).ddp_request_code; -- return gia tri input
      --> insert bang luu
	    if x_return_status = 'S' then
	 insert into FPT_DDP_SALESPESON
		 (ddp_id,
			STT,
			X_RESOURCE_ID,
			X_RESOURCE_NUMBER,
			X_SALESREP_ID,
			ddp_request_code)
	 values
		 (p_ddp_id,
			vTab_index,
			x_Saleperson_tbl_Type_out(vTab_index).X_RESOURCE_ID,
			x_Saleperson_tbl_Type_out(vTab_index).X_RESOURCE_NUMBER,
			x_Saleperson_tbl_Type_out(vTab_index).X_SALESREP_ID,
			x_Saleperson_tbl_Type_out(vTab_index).ddp_request_code);  
   end if;
   
    end;
   
   
		vTab_index := vTab_index + 1;
		exit when x_return_status != 'S';
	end loop;
  
   
	--> return if insert error
	if (x_return_status <> fnd_api.g_ret_sts_success) then
    rollback to create_batch_salesrep_all;
		return;
	end if;
  
   --> update trang thai ddp_id
    update fpt_ddp_process
   set Status = 'S',
      end_time = sysdate
   where ddp_id = p_ddp_id
   and program = 'Create_Saleperson' ;
   
 /* --> insert log
  update Fpt_Salespeson_number t
  set t.status = 'S'
  where t.ddp_id = p_DDP_ID;*/



	
end;
END JTF_RS_SALESREPS_PUB_V3 ;
/
