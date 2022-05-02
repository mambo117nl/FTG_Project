CREATE OR REPLACE PACKAGE FPT_DDP_KQ_CANCEL_PUB_V1  AS
/* $Header: FPT_DDP_KQ_CANCEL_PUB_V1.pls 120.3 2022/02/13 18:56:53 repuri ship$ */
/*#
 * Salesperson create and update API
 * This API contains the procedures to export payment Kyquy to DDP.
 * @rep:scope public
 * @rep:product AP
 * @rep:displayname Fpt Cancel kyquy API
 * @rep:category BUSINESS_ENTITY FPT_DDP_KYQUY_CANCEL
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf CMM APIs,  Oracle Trading Community Architecture Technical Implementation Guide

*/
  /*****************************************************************************************
   This is a public API that caller will invoke. 
   It provides procedures for export cancel Kyquy to DDP.
   Its main procedures are as following:
   Fpt Cancel Kyquy API
   ******************************************************************************************/


TYPE DDP_Kyquy_Cancel_Type IS RECORD (
      DDP_REQUEST_CODE  VARCHAR2(50),
      ORG_ID            NUMBER,
      INVOICE_ID        number,
      VOID_DATE         VARCHAR2(50), 
      RECEIPT_ID        number,      
      comments          ar_cash_receipts_all.comments%type
  );
  
  
TYPE DDP_Kyquy_Cancel_Tbl IS TABLE OF DDP_Kyquy_Cancel_Type INDEX BY BINARY_INTEGER;



/* Procedure to create API AP_INV_CANCEL 
  based on input values passed by calling routines. */
/*#
 * Create AP_INV_CANCEL API   
 * This procedure allows the user to export cancel kyquy record.
 * @param P_DDP_ID ddp_id
 * @param P_KYQUY_CANCEL_INF tbl cancel kyquy
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
 * @param x_ddp_request_code ddp code record out.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Cancel kyquy API
 */ 
PROCEDURE  AP_INV_CANCEL(P_DDP_ID                     IN VARCHAR2,
                         P_KYQUY_CANCEL_INF           IN DDP_KYQUY_CANCEL_TBL,    
                         X_RETURN_STATUS              OUT NOCOPY VARCHAR2,
                         X_MSG_COUNT                  OUT NOCOPY NUMBER,
                         X_MSG_DATA                   OUT NOCOPY VARCHAR2,
                         X_DDP_REQUEST_CODE           OUT NOCOPY VARCHAR2);  

END FPT_DDP_KQ_CANCEL_PUB_V1;
/
CREATE OR REPLACE PACKAGE BODY FPT_DDP_KQ_CANCEL_PUB_V1  AS
/* $Header: FPT_DDP_KQ_CANCEL_PUB_V1.pls 120.3 2022/02/13 18:56:53  repuri ship $ */

  /* Package variables. */

  --G_PKG_NAME         CONSTANT VARCHAR2(30) := 'FPT_DDP_KQ_CANCEL_PUB_V1';

 
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

 function check_invoice(p_invoice_id number) return boolean is
    v_chk number;
  begin
    select count(1)
      into v_chk
      from ap_invoices_all
     where invoice_id = p_invoice_id
     ;
    if nvl(v_chk,0) = 0 then
      return false;
      else
      return  true;
        end if;
  exception
    when others then
      return false;
  end;
  
/* function get_invoice_id(p_invoice_num varchar2) return number is
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
  end;*/
  
  function check_receipt(p_receipt_id number) return boolean is
    v_chk number;
  begin
    select  count(1)
      into v_chk
      from ar_cash_receipts_all t
     where t.cash_receipt_id = p_receipt_id
       ;
    if nvl(v_chk,0) = 0 then
      return false;
      else
      return  true;
        end if;
  exception
    when others then
      return false;
  end;
  
  Function Is_Invoice_Cancellable(
               P_invoice_id        IN NUMBER,
               P_error_code           OUT NOCOPY VARCHAR2,   /* Bug 5300712 */
               P_debug_info        IN OUT NOCOPY VARCHAR2,
               P_calling_sequence  IN            VARCHAR2) RETURN BOOLEAN
  IS

    CURSOR verify_no_pay_batch IS
    SELECT checkrun_id
      FROM ap_payment_schedules
     WHERE invoice_id = P_invoice_id
     FOR UPDATE NOWAIT;

   -- Bug5497058
   CURSOR qty_per_dist_negtive_count_cur IS
   SELECT count(*)
   FROM ap_invoice_distributions AID,
          po_distributions_ap_v POD,
    po_line_locations PLL,
    po_lines PL,
          ap_invoices AIV
    WHERE POD.po_distribution_id = AID.po_distribution_id
      AND POD.line_location_id = PLL.line_location_id
      AND PLL.po_line_id = PL.po_line_id
      AND AIV.invoice_id=AID.invoice_id
      AND NVL(AID.reversal_flag, 'N') <> 'Y'
      AND AID.invoice_id = P_invoice_id
       -- Bug 5590826. For amount related decode
      AND AID.line_type_lookup_code IN ('ITEM', 'ACCRUAL', 'IPV')
   HAVING (DECODE(AIV.invoice_type_lookup_code,'PREPAYMENT',
             SUM(NVL(POD.quantity_financed, 0)),SUM(NVL(POD.quantity_billed, 0))
     ) -
             SUM(round(decode(AID.dist_match_type,
                             'PRICE_CORRECTION', 0,
                             'AMOUNT_CORRECTION', 0,
                             'ITEM_TO_SERVICE_PO', 0,
                             'ITEM_TO_SERVICE_RECEIPT', 0,
                              nvl( AID.quantity_invoiced, 0 ) +
                              nvl( AID.corrected_quantity,0 )
           ) *
                 po_uom_s.po_uom_convert(AID.matched_uom_lookup_code,         --bug5844328
                               nvl(PLL.unit_meas_lookup_code,
                 PL.unit_meas_lookup_code),
             PL.item_id), 15)
          ) < 0
           OR DECODE(AIV.invoice_type_lookup_code,'PREPAYMENT',
              SUM(NVL(POD.amount_financed, 0)),SUM(NVL(POD.amount_billed, 0))) -
              SUM(NVL(AID.amount, 0)) < 0 )
    GROUP BY AIV.invoice_type_lookup_code,AID.po_distribution_id;


    CURSOR dist_gl_date_cur IS
    SELECT accounting_date
      FROM ap_invoice_distributions AID
     WHERE AID.invoice_id = P_invoice_id
       AND NVL(AID.reversal_flag, 'N') <> 'Y';

    TYPE date_tab is TABLE OF DATE INDEX BY BINARY_INTEGER;
    l_gl_date_list              date_tab;
    i                           BINARY_INTEGER := 1;
    l_open_gl_date              DATE :='';
    l_open_period               gl_period_statuses.period_name%TYPE := '';

    l_curr_calling_sequence     VARCHAR2(2000);
    l_debug_info                VARCHAR2(100):= 'Is_Invoice_Cancellable';

    l_checkrun_id               NUMBER;
    l_cancel_count              NUMBER := 0;
    l_project_related_count     NUMBER := 0;
    l_payment_count             NUMBER := 0;
    l_final_close_count         NUMBER := 0;
    l_prepay_applied_flag       VARCHAR2(1);
    l_po_dist_count             NUMBER := 0;
    l_credited_inv_flag         BOOLEAN := FALSE;
    l_pa_message_name           VARCHAR2(50);
    l_org_id                    NUMBER;
    l_final_closed_shipment_count NUMBER;
    l_allow_cancel              VARCHAR2(1) := 'Y';
    l_return_code               VARCHAR2(30);
    l_enc_enabled               VARCHAR2(1);  --Bug6009101
    l_po_not_approved           VARCHAR2(1);  --Bug6009101


  BEGIN
    l_curr_calling_sequence := 'AP_INVOICE_PKG.IS_INVOICE_CANCELLABLE<-' ||
                               P_calling_sequence;

    /*-----------------------------------------------------------------+
     |  Step 0 - If invoice contain distribtuion which does not have   |
     |           OPEN gl period name, return FALSE                     |
     +-----------------------------------------------------------------*/
    /* bug 4942638. Move the next select here */
    l_debug_info := 'Get the org_id for the invoice';

    SELECT org_id
    INTO   l_org_id
    FROM   ap_invoices_all
    WHERE  invoice_id = p_invoice_id;

    l_debug_info := 'Check if inv distribution has open period';

    OPEN dist_gl_date_Cur;
    FETCH dist_gl_date_Cur
    BULK COLLECT INTO l_gl_date_list;
    CLOSE dist_gl_date_Cur;

    /* Bug 5354259. Added the following IF condition as for
       For unvalidated invoice case most of the cases there wil be no distributions */
    IF l_gl_date_list.count > 0 THEN
    FOR i in l_gl_date_list.FIRST..l_gl_date_list.LAST
    LOOP
      /* bug 4942638. Added l_org_id in the next two function call */
      l_open_period := ap_utilities_pkg.get_current_gl_date(l_gl_date_list(i), l_org_id);
      IF ( l_open_period IS NULL ) THEN
        ap_utilities_pkg.get_open_gl_date(
                 l_gl_date_list(i),
                 l_open_period,
                 l_open_gl_date,
                 l_org_id);
        IF ( l_open_period IS NULL ) THEN
          p_error_code := 'AP_DISTS_NO_OPEN_FUT_PERIOD';
          p_debug_info := l_debug_info;
          RETURN FALSE;
        END IF;
      END IF;
    END LOOP;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 1 - If invoice has an effective payment, return FALSE     |
     |           This include the check of if invoice itself is a      |
     |           PREPAYMENT type invoice - Actively referenced         |
     |           prepayment type invoice has to be fully paid when it  |
     |           is applied.                                           |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoice has an effective payment';

     SELECT   count(*)
      INTO   l_payment_count
      FROM   ap_invoice_payments P,ap_payment_schedules PS
     WHERE   P.invoice_id=PS.invoice_id
       AND   P.invoice_id = P_invoice_id
       AND   PS.payment_status_flag <> 'N'
       AND   nvl(P.reversal_flag,'N') <> 'Y'
       AND   P.amount is not NULL
       AND   exists ( select 'non void check'
                      from ap_checks A
                      where A.check_id = P.check_id
                        and void_date is null);--Bug 6135172

    IF ( l_payment_count <> 0 ) THEN
      P_error_code := 'invoice has an effective payment';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 2. If invoice is selected for payment, return FALSE       |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoice is selected for payment';

    BEGIN
      OPEN verify_no_pay_batch;
      LOOP
      FETCH verify_no_pay_batch
       INTO l_checkrun_id;
      EXIT WHEN verify_no_pay_batch%NOTFOUND;
        IF l_checkrun_id IS NOT NULL THEN
          P_error_code := 'invoice is selected for payment';
          P_debug_info := l_debug_info || 'with no check run id';
          COMMIT;
          RETURN FALSE;
        END IF;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        IF ( verify_no_pay_batch%ISOPEN ) THEN
          CLOSE verify_no_pay_batch;
        END IF;
        P_error_code := 'AP_INV_CANCEL_PS_LOCKED';
        P_debug_info := l_debug_info || 'With exceptions';
        COMMIT;
        RETURN FALSE;
    END;

    /*-----------------------------------------------------------------+
     |  Step 3. If invoice is already cancelled, return FALSE          |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoice is already cancelled';

    SELECT count(*)
    INTO   l_cancel_count
    FROM   ap_invoices
    WHERE  invoice_id = P_invoice_id
    AND    cancelled_date IS NOT NULL;

    IF (l_cancel_count > 0) THEN
      P_error_code := 'invoice is already cancelled';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 4. If invoice is a credited invoice return FALSE          |
     +-----------------------------------------------------------------*/
    l_debug_info := 'Check if invoice is a credited invoice';

    l_credited_inv_flag := AP_INVOICES_UTILITY_PKG.Is_Inv_Credit_Referenced(
                               P_invoice_id);

    IF (l_credited_inv_flag <> FALSE ) THEN
      P_error_code := 'invoice is a credited invoice';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 5. If invoices have been applied against this invoice     |
     |          return FALSE                                           |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoices have been applied against this invoice';

    l_prepay_applied_flag :=
        AP_INVOICES_UTILITY_PKG.get_prepayments_applied_flag(P_invoice_id);

    IF (nvl(l_prepay_applied_flag,'N') = 'Y') THEN
      P_error_code := 'invoices have been applied against this invoice';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 6. If invoice is matched to a Finally Closed PO, return   |
     |          FALSE                                                  |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Check if invoice is matched to a finally closed PO';

    -- Bug fix:3488316
    -- Following code in this step has been added for JFMIP related work.
    -- This code has been modified only for federal customers, before modifying
    -- this code please get the code verified with the developer/manager
    -- who added this code.
    /* bug 4942638. Move the next select for l_org_id at the begining */

    IF (FV_INSTALL.ENABLED (l_org_id)) THEN

       BEGIN

          SELECT 'N'
          INTO l_allow_cancel
          FROM ap_invoice_distributions AID,
               po_distributions PD,
               po_line_locations pll
          WHERE aid.invoice_id = p_invoice_id
          --AND aid.final_match_flag in ('N','Y')  For Bug 3489536
          AND aid.po_distribution_id = pd.po_distribution_id
          AND pll.line_location_id = pd.line_location_id
          AND decode(pll.final_match_flag, 'Y', 'D', aid.final_match_flag) in ('N','Y') --Bug 3489536
          AND pll.closed_code = 'FINALLY CLOSED'
          AND rownum = 1;

          IF (l_allow_cancel = 'N') THEN
             P_error_code := 'AP_INV_CANNOT_OPEN_SHIPMENT';
             P_debug_info := l_debug_info;
        RETURN(FALSE);
          END IF;

       EXCEPTION
        WHEN NO_DATA_FOUND THEN

          SELECT count(distinct pll.line_location_id)
          INTO l_final_closed_shipment_count
          FROM ap_invoice_distributions aid,
               po_line_locations pll,
               po_distributions pd
          WHERE aid.invoice_id = p_invoice_id
          AND aid.po_distribution_id = pd.po_distribution_id
          AND pd.line_location_id = pll.line_location_id
          --AND aid.final_match_flag = 'D' For bug 3489536
          AND decode(pll.final_match_flag, 'Y', 'D', aid.final_match_flag) = 'D' --Bug 3489536
          AND pll.closed_code = 'FINALLY CLOSED';

       END ;

       IF (l_final_closed_shipment_count > 1) THEN

            P_error_code := 'AP_INV_MUL_SHIP_FINALLY_CLOSED' ;
          P_debug_info := l_debug_info;
            RETURN(FALSE);

        END IF;

        IF (l_final_closed_shipment_count = 1) THEN

          l_debug_info := 'Open the Finally Closed PO Shipment ';
          IF(NOT(FV_AP_CANCEL_PKG.OPEN_PO_SHIPMENT(p_invoice_id,
                                                  l_return_code))) THEN

            P_error_code := 'AP_INV_CANNOT_OPEN_SHIPMENT';
            P_debug_info := l_debug_info;
            RETURN(FALSE);

          END IF;

        END IF;

    ELSE


    SELECT count(*)
    INTO   l_final_close_count
    FROM   ap_invoice_lines AIL,
           po_line_locations_ALL PL
    WHERE  AIL.invoice_id = P_invoice_id
    AND    AIL.po_line_location_id = PL.line_location_id
    AND    AIL.org_id = PL.org_id
    AND    PL.closed_code = 'FINALLY CLOSED';

    IF (l_final_close_count > 0) THEN
      P_error_code := 'AP_INV_PO_FINALLY_CLOSED';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;
    END IF;
    /*-----------------------------------------------------------------+
     |  Step 7. If projects have pending adjustments then return FALSE |
     +-----------------------------------------------------------------*/
    --
    -- Bug 5349193
    -- As suggested in the bug, this validation is commented in R12.
    --

    /* SELECT count(*)
    INTO   l_project_related_count
    FROM   ap_invoices AI
    WHERE  AI.invoice_id = P_invoice_id
    AND    (AI.project_id is not null OR
            exists (select 'X'
                    from   ap_invoice_distributions AIL
                    where  AIL.invoice_id = AI.invoice_id
                    and    project_id is not null) OR
            exists (select 'X'
                    from   ap_invoice_distributions AID
                    where  AID.invoice_id = AI.invoice_id
                    and    project_id is not null));

    IF (l_project_related_count <> 0) THEN
      l_pa_message_name := pa_integration.pending_vi_adjustments_exists(
                                   P_invoice_id);
      IF (l_pa_message_name <> 'N') THEN
        P_error_code := l_pa_message_name;
        P_debug_info := l_debug_info;
        RETURN FALSE;
      END IF;
    END IF; */

    /*-----------------------------------------------------------------+
     |  Step 8. if the quantity billed and amount on PO would be       |
     |          reduced to less than zero then return FALSE            |
     |          Always allow Reversal distributions to be cancelled    |
     +-----------------------------------------------------------------*/

    BEGIN

      OPEN qty_per_dist_negtive_count_cur;
      FETCH qty_per_dist_negtive_count_cur
      INTO l_po_dist_count;
      CLOSE qty_per_dist_negtive_count_cur;

    END;

    IF ( l_po_dist_count > 0 ) THEN
      P_error_code := 'AP_INV_PO_CANT_CANCEL';
      P_debug_info := l_debug_info;
      RETURN FALSE;
    END IF;

    /*-----------------------------------------------------------------+
     |  Step 9. if the invoice is matched to an unapproved PO, if the
     |          encumbrance is on, then do not allow the invoice
     |    cancellation (bug6009101)
     *-----------------------------------------------------------------*/

  l_debug_info := 'Check if the PO is unapproved';

   SELECT NVL(purch_encumbrance_flag,'N')
   INTO   l_enc_enabled
   FROM   financials_system_params_all
   WHERE  NVL(org_id, -99) = NVL(l_org_id, -99);

    if l_enc_enabled = 'Y' then

       begin

          select 'Y'
          into   l_po_not_approved
          from   po_headers POH,
                 po_distributions POD,
                 ap_invoice_distributions AID,
                 ap_invoices AI
          where  AI.invoice_id = AID.invoice_id
          and    AI.invoice_id = P_invoice_id
          and    AID.po_distribution_id = POD.po_distribution_id
          and    POD.po_header_id = POH.po_header_id
          and    POH.approved_flag <> 'Y'
          and    rownum = 1;

          EXCEPTION
             WHEN OTHERS THEN
                  NULL;

      end;

      if l_po_not_approved = 'Y' then
         p_error_code := 'AP_PO_UNRES_CANT_CANCEL';
         p_debug_info := l_debug_info;
         return FALSE;
       end if;
    end if;


    p_error_code := null;
    P_debug_info := l_debug_info;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             ' P_invoice_id = '     || P_invoice_id );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF (qty_per_dist_negtive_count_cur%ISOPEN ) THEN
        CLOSE qty_per_dist_negtive_count_cur;
      END IF;

      IF ( dist_gl_date_cur%ISOPEN ) THEN
        CLOSE dist_gl_date_cur;
      END IF;

      P_debug_info := l_debug_info || 'With exceptions';
      RETURN FALSE;

  END Is_Invoice_Cancellable;
  
  PROCEDURE AP_CHECK_CANCEL_INVOICE(P_INVOICE_ID NUMBER,
                                  X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
                                 X_MSG_COUNT                 OUT NOCOPY NUMBER,
                                X_MSG_DATA                  OUT NOCOPY VARCHAR2) IS
  result boolean;
  p_error_code varchar2(100);
  p_debug_info varchar2(100);
  p_calling_sequence  varchar2(100) := 'AP_CHECK_CANCEL_INVOICE';
begin
 
  -- Call the function
  result := is_invoice_cancellable(p_invoice_id => P_INVOICE_ID,
                                                 p_error_code => p_error_code,
                                                 p_debug_info => p_debug_info,
                                                 p_calling_sequence => p_calling_sequence);
  -- Convert false/true/null to 0/1/null 
  
IF RESULT = FALSE  THEN
    X_RETURN_STATUS    := 'E';
      X_MSG_COUNT        := 1;
      X_MSG_DATA         := p_error_code;
 END IF;

        
EXCEPTION WHEN
  OTHERS THEN
    X_RETURN_STATUS    := 'E';
      X_MSG_COUNT        := 1;
      X_MSG_DATA         := SQLERRM;

END ;


  /*Procedure Is_Invoice_Cancellable(P_invoice_id     IN NUMBER,
                                   X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                                   X_MSG_COUNT      OUT NOCOPY NUMBER,
                                   X_MSG_DATA       OUT NOCOPY VARCHAR2) IS
 
  v_count      number := 0;
  p_error_code  varchar2(2000);
  --P_debug_info VARCHAR2(1000);

  CURSOR verify_no_pay_batch IS
    SELECT checkrun_id
      FROM ap_payment_schedules
     WHERE invoice_id = P_invoice_id
       FOR UPDATE NOWAIT;

  -- Bug5497058
  CURSOR qty_per_dist_negtive_count_cur IS
    SELECT count(*)
      FROM ap_invoice_distributions AID,
           po_distributions_ap_v    POD,
           po_line_locations        PLL,
           po_lines                 PL,
           ap_invoices              AIV
     WHERE POD.po_distribution_id = AID.po_distribution_id
       AND POD.line_location_id = PLL.line_location_id
       AND PLL.po_line_id = PL.po_line_id
       AND AIV.invoice_id = AID.invoice_id
       AND NVL(AID.reversal_flag, 'N') <> 'Y'
       AND AID.invoice_id = P_invoice_id
          -- Bug 5590826. For amount related decode
       AND AID.line_type_lookup_code IN ('ITEM', 'ACCRUAL', 'IPV')
     HAVING(DECODE(AIV.invoice_type_lookup_code,
                         'PREPAYMENT',
                         SUM(NVL(POD.quantity_financed, 0)),
                         SUM(NVL(POD.quantity_billed, 0))) -
                  SUM(round(decode(AID.dist_match_type,
                                   'PRICE_CORRECTION',
                                   0,
                                   'AMOUNT_CORRECTION',
                                   0,
                                   'ITEM_TO_SERVICE_PO',
                                   0,
                                   'ITEM_TO_SERVICE_RECEIPT',
                                   0,
                                   nvl(AID.quantity_invoiced, 0) +
                                   nvl(AID.corrected_quantity, 0)) *
                            po_uom_s.po_uom_convert(AID.matched_uom_lookup_code, --bug5844328
                                                    nvl(PLL.unit_meas_lookup_code,
                                                        PL.unit_meas_lookup_code),
                                                    PL.item_id),
                            15)) < 0
               OR DECODE(AIV.invoice_type_lookup_code,
                         'PREPAYMENT',
                         SUM(NVL(POD.amount_financed, 0)),
                         SUM(NVL(POD.amount_billed, 0))) -
                  SUM(NVL(AID.amount, 0)) < 0)
     GROUP BY AIV.invoice_type_lookup_code, AID.po_distribution_id;

  CURSOR dist_gl_date_cur IS
    SELECT accounting_date
      FROM ap_invoice_distributions AID
     WHERE AID.invoice_id = P_invoice_id
       AND NVL(AID.reversal_flag, 'N') <> 'Y';

  TYPE date_tab is TABLE OF DATE INDEX BY BINARY_INTEGER;
  l_gl_date_list date_tab;
  i              BINARY_INTEGER := 1;
  l_open_gl_date DATE := '';
  l_open_period  gl_period_statuses.period_name%TYPE := '';
  l_checkrun_id  NUMBER;
  l_cancel_count NUMBER := 0;
  --l_project_related_count     NUMBER := 0;
  l_payment_count       NUMBER := 0;
  l_final_close_count   NUMBER := 0;
  l_prepay_applied_flag VARCHAR2(1);
  l_po_dist_count       NUMBER := 0;
  l_credited_inv_flag   BOOLEAN := FALSE;
  --l_pa_message_name           VARCHAR2(50);
  l_org_id                      NUMBER;
  l_final_closed_shipment_count NUMBER;
  l_allow_cancel                VARCHAR2(1) := 'Y';
  l_return_code                 VARCHAR2(30);
  l_enc_enabled                 VARCHAR2(1); --Bug6009101
  l_po_not_approved             VARCHAR2(1); --Bug6009101

BEGIN
  EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = APPS';
  \*-----------------------------------------------------------------+
  |  Step 0 - If invoice contain distribtuion which does not have   |
  |           OPEN gl period name, RETURN                      |
  +-----------------------------------------------------------------*\

  --l_debug_info := 'Get the org_id for the invoice';

  SELECT org_id
    INTO l_org_id
    FROM ap_invoices_all
   WHERE invoice_id = p_invoice_id;

  --l_debug_info := 'Check if inv distribution has open period';

  OPEN dist_gl_date_Cur;
  FETCH dist_gl_date_Cur BULK COLLECT
    INTO l_gl_date_list;
  CLOSE dist_gl_date_Cur;

  IF l_gl_date_list.count > 0 THEN
    FOR i in l_gl_date_list.FIRST .. l_gl_date_list.LAST LOOP
    
      l_open_period := ap_utilities_pkg.get_current_gl_date(l_gl_date_list(i),
                                                            l_org_id);
      IF (l_open_period IS NULL) THEN
        ap_utilities_pkg.get_open_gl_date(l_gl_date_list(i),
                                          l_open_period,
                                          l_open_gl_date,
                                          l_org_id);
        IF (l_open_period IS NULL) THEN
          p_error_code := 'AP_DISTS_NO_OPEN_FUT_PERIOD';        
          X_MSG_COUNT := 1;
          RETURN  ;
        END IF;
      END IF;
    END LOOP;
  END IF;

  \*-----------------------------------------------------------------+
  |  Step 1 - If invoice has an effective payment, RETURN      |
  |           This include the check of if invoice itself is a      |
  |           PREPAYMENT type invoice - Actively referenced         |
  |           prepayment type invoice has to be fully paid when it  |
  |           is applied.                                           |
  +-----------------------------------------------------------------*\

  --l_debug_info := 'Check if invoice has an effective payment';

  SELECT count(*)
    INTO l_payment_count
    FROM ap_invoice_payments P, ap_payment_schedules PS
   WHERE P.invoice_id = PS.invoice_id
     AND P.invoice_id = P_invoice_id
     AND PS.payment_status_flag <> 'N'
     AND nvl(P.reversal_flag, 'N') <> 'Y'
     AND P.amount is not NULL
     AND exists (select 'non void check'
            from ap_checks A
           where A.check_id = P.check_id
             and void_date is null); --Bug 6135172

  IF (l_payment_count <> 0) THEN
    P_error_code := 'Payment for this invoice exists';
  
    v_count := v_count + 1;
    RETURN ;
  END IF;

  \*-----------------------------------------------------------------+
  |  Step 2. If invoice is selected for payment, RETURN        |
  +-----------------------------------------------------------------*\

  --l_debug_info := 'Check if invoice is selected for payment';

  BEGIN
    OPEN verify_no_pay_batch;
    LOOP
      FETCH verify_no_pay_batch
        INTO l_checkrun_id;
      EXIT WHEN verify_no_pay_batch%NOTFOUND;
      IF l_checkrun_id IS NOT NULL THEN
        P_error_code := 'AP_INV_CANCEL_SEL_PAYMENT';
        v_count      := v_count + 1;
        COMMIT;
         RETURN ;
      END IF;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF (verify_no_pay_batch%ISOPEN) THEN
        CLOSE verify_no_pay_batch;
      END IF;
      P_error_code := 'invoice is selected for payment';
      v_count      := v_count + 1;
      COMMIT;
      RETURN ;
  END;

  \*-----------------------------------------------------------------+
  |  Step 3. If invoice is already cancelled, RETURN           |
  +-----------------------------------------------------------------*\

  --l_debug_info := 'Check if invoice is already cancelled';

  SELECT count(*)
    INTO l_cancel_count
    FROM ap_invoices
   WHERE invoice_id = P_invoice_id
     AND cancelled_date IS NOT NULL;

  IF (l_cancel_count > 0) THEN
    P_error_code := 'invoice is already cancelled';
    v_count      := v_count + 1;
    RETURN ;
  END IF;

  \*-----------------------------------------------------------------+
  |  Step 4. If invoice is a credited invoice RETURN           |
  +-----------------------------------------------------------------*\
  --l_debug_info := 'Check if invoice is a credited invoice';

  l_credited_inv_flag := AP_INVOICES_UTILITY_PKG.Is_Inv_Credit_Referenced(P_invoice_id);

  IF (l_credited_inv_flag <> FALSE) THEN
    P_error_code := 'invoice is a credited invoice';
    v_count      := v_count + 1;
   RETURN ;
  END IF;

  \*-----------------------------------------------------------------+
  |  Step 5. If invoices have been applied against this invoice     |
  |          RETURN                                            |
  +-----------------------------------------------------------------*\

  --l_debug_info := 'Check if invoices have been applied against this invoice';

  l_prepay_applied_flag := AP_INVOICES_UTILITY_PKG.get_prepayments_applied_flag(P_invoice_id);

  IF (nvl(l_prepay_applied_flag, 'N') = 'Y') THEN
    P_error_code := 'invoices have been applied against this invoice';
    v_count      := v_count + 1;
   RETURN ;
  END IF;

  \*-----------------------------------------------------------------+
  |  Step 6. If invoice is matched to a Finally Closed PO, return   |
  |          FALSE                                                  |
  +-----------------------------------------------------------------*\

  --l_debug_info := 'Check if invoice is matched to a finally closed PO';

  IF (FV_INSTALL.ENABLED(l_org_id)) THEN
  
    BEGIN
    
      SELECT 'N'
        INTO l_allow_cancel
        FROM ap_invoice_distributions AID,
             po_distributions         PD,
             po_line_locations        pll
       WHERE aid.invoice_id = p_invoice_id
            --AND aid.final_match_flag in ('N','Y')  For Bug 3489536
         AND aid.po_distribution_id = pd.po_distribution_id
         AND pll.line_location_id = pd.line_location_id
         AND decode(pll.final_match_flag, 'Y', 'D', aid.final_match_flag) in
             ('N', 'Y') --Bug 3489536
         AND pll.closed_code = 'FINALLY CLOSED'
         AND rownum = 1;
    
      IF (l_allow_cancel = 'N') THEN
        P_error_code := 'invoice is matched to a finally closed PO';
        v_count      := v_count + 1;
        RETURN;
      END IF;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      
        SELECT count(distinct pll.line_location_id)
          INTO l_final_closed_shipment_count
          FROM ap_invoice_distributions aid,
               po_line_locations        pll,
               po_distributions         pd
         WHERE aid.invoice_id = p_invoice_id
           AND aid.po_distribution_id = pd.po_distribution_id
           AND pd.line_location_id = pll.line_location_id
              --AND aid.final_match_flag = 'D' For bug 3489536
           AND decode(pll.final_match_flag, 'Y', 'D', aid.final_match_flag) = 'D' --Bug 3489536
           AND pll.closed_code = 'FINALLY CLOSED';
      
    END;
  
    IF (l_final_closed_shipment_count > 1) THEN
    
      P_error_code := 'AP_INV_MUL_SHIP_FINALLY_CLOSED';
    
      v_count := v_count + 1;
      RETURN;
    
    END IF;
  
    IF (l_final_closed_shipment_count = 1) THEN
    
      --l_debug_info := 'Open the Finally Closed PO Shipment ';
      IF (NOT
          (FV_AP_CANCEL_PKG.OPEN_PO_SHIPMENT(p_invoice_id, l_return_code))) THEN
      
        P_error_code := 'AP_INV_CANNOT_OPEN_SHIPMENT';
      
        v_count := v_count + 1;
         RETURN;
      
      END IF;
    
    END IF;
  
  ELSE
  
    SELECT count(*)
      INTO l_final_close_count
      FROM ap_invoice_lines AIL, po_line_locations_ALL PL
     WHERE AIL.invoice_id = P_invoice_id
       AND AIL.po_line_location_id = PL.line_location_id
       AND AIL.org_id = PL.org_id
       AND PL.closed_code = 'FINALLY CLOSED';
  
    IF (l_final_close_count > 0) THEN
      P_error_code := 'AP_INV_PO_FINALLY_CLOSED';
    
      v_count := v_count + 1;
      RETURN ;
    END IF;
  END IF;

  \*-----------------------------------------------------------------+
  |  Step 8. if the quantity billed and amount on PO would be       |
  |          reduced to less than zero then RETURN             |
  |          Always allow Reversal distributions to be cancelled    |
  +-----------------------------------------------------------------*\

  BEGIN
  
    OPEN qty_per_dist_negtive_count_cur;
    FETCH qty_per_dist_negtive_count_cur
      INTO l_po_dist_count;
    CLOSE qty_per_dist_negtive_count_cur;
  
  END;

  IF (l_po_dist_count > 0) THEN
    P_error_code := 'AP_INV_PO_CANT_CANCEL';  
    v_count := v_count + 1;
    RETURN ;
  END IF;

  \*-----------------------------------------------------------------+
  |  Step 9. if the invoice is matched to an unapproved PO, if the
  |          encumbrance is on, then do not allow the invoice
  |    cancellation (bug6009101)
  *-----------------------------------------------------------------*\

  --l_debug_info := 'Check if the PO is unapproved';

  SELECT NVL(purch_encumbrance_flag, 'N')
    INTO l_enc_enabled
    FROM financials_system_params_all
   WHERE NVL(org_id, -99) = NVL(l_org_id, -99);

  if l_enc_enabled = 'Y' then
  
    begin
    
      select 'Y'
        into l_po_not_approved
        from po_headers               POH,
             po_distributions         POD,
             ap_invoice_distributions AID,
             ap_invoices              AI
       where AI.invoice_id = AID.invoice_id
         and AI.invoice_id = P_invoice_id
         and AID.po_distribution_id = POD.po_distribution_id
				 and POD.po_header_id = POH.po_header_id
				 and POH.approved_flag <> 'Y'
				 and rownum = 1;
		
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
			
		end;
	
		if l_po_not_approved = 'Y' then
			p_error_code := 'AP_PO_UNRES_CANT_CANCEL';	
			v_count := v_count + 1;
			RETURN ;
		end if;
	end if;
  
  if v_count = 0 then
  X_RETURN_STATUS           := 'S';
  X_MSG_COUNT            := 1;
  X_MSG_DATA  := p_error_code;
   end if;

EXCEPTION
	WHEN OTHERS THEN
		X_RETURN_STATUS           := 'E';
    X_MSG_COUNT            := 1;
     X_MSG_DATA  := sqlerrm;
		
    RETURN ;
	
END Is_Invoice_Cancellable;*/

/*PROCEDURE AP_CANCEL_INVOCIE(P_INVOICE_ID        IN NUMBER,
                            P_ACCOUNTING_DATE   IN DATE,
                            P_ORG_ID            IN Number,
														X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
													  X_MSG_COUNT         OUT NOCOPY NUMBER,
													  X_MSG_DATA          OUT NOCOPY VARCHAR2) IS

   RESULT                       BOOLEAN;
   --V_DONE                       NUMBER;
   P_MESSAGE_NAME               VARCHAR2(100);
   P_INVOICE_AMOUNT             NUMBER;
   P_BASE_AMOUNT                NUMBER;
   P_TEMP_CANCELLED_AMOUNT      NUMBER;
   P_CANCELLED_BY               NUMBER;
   P_CANCELLED_AMOUNT           NUMBER;
   P_CANCELLED_DATE             DATE;
   P_LAST_UPDATE_DATE           DATE;
   P_ORIGINAL_PREPAYMENT_AMOUNT NUMBER;
   P_PAY_CURR_INVOICE_AMOUNT    NUMBER;
	 P_TOKEN			                VARCHAR2(100);
BEGIN
  APPS.MO_GLOBAL.INIT('SQLAP');
  --
  APPS.FND_GLOBAL.APPS_INITIALIZE(0,51612,200);
  
  EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = APPS';
  --
  MO_GLOBAL.SET_POLICY_CONTEXT('S',P_ORG_ID);
  -- CALL THE FUNCTION
  RESULT := AP_CANCEL_PKG.AP_CANCEL_SINGLE_INVOICE(P_INVOICE_ID                 => P_INVOICE_ID,
                                                   P_LAST_UPDATED_BY            => 0,
                                                   P_LAST_UPDATE_LOGIN          => 0,
                                                   P_ACCOUNTING_DATE            => P_ACCOUNTING_DATE,
                                                   P_MESSAGE_NAME               => P_MESSAGE_NAME,
                                                   P_INVOICE_AMOUNT             => P_INVOICE_AMOUNT,
                                                   P_BASE_AMOUNT                => P_BASE_AMOUNT,
                                                   P_TEMP_CANCELLED_AMOUNT      => P_TEMP_CANCELLED_AMOUNT,
                                                   P_CANCELLED_BY               => P_CANCELLED_BY,
                                                   P_CANCELLED_AMOUNT           => P_CANCELLED_AMOUNT,
                                                   P_CANCELLED_DATE             => P_CANCELLED_DATE,
                                                   P_LAST_UPDATE_DATE           => P_LAST_UPDATE_DATE,
                                                   P_ORIGINAL_PREPAYMENT_AMOUNT => P_ORIGINAL_PREPAYMENT_AMOUNT,
                                                   P_PAY_CURR_INVOICE_AMOUNT    => P_PAY_CURR_INVOICE_AMOUNT,
                                                   P_TOKEN                      => P_TOKEN,
                                                   P_CALLING_SEQUENCE           => 'FPT_DDP_KQ_CANCEL_INVOICE');
  

  -- CONVERT FALSE/TRUE/NULL TO 0/1/NULL 
 --V_DONE := SYS.DIUTIL.BOOL_TO_INT(RESULT);
 IF RESULT = FALSE  THEN
    X_RETURN_STATUS    := 'E';
    X_MSG_COUNT        := 1;
    X_MSG_DATA         := 'Canncel Invoice is error!'; 
 END IF;        
EXCEPTION 
  WHEN OTHERS THEN
    X_RETURN_STATUS    := 'E';
    X_MSG_COUNT        := 1;
    X_MSG_DATA         := SQLERRM;
END AP_CANCEL_INVOCIE;*/

PROCEDURE AP_CANCEL_INVOCIE(P_INVOICE_ID NUMBER,
                            P_ACCOUNTING_DATE            IN DATE,
																	X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
													     	X_MSG_COUNT                 OUT NOCOPY NUMBER,
													      X_MSG_DATA                  OUT NOCOPY VARCHAR2) IS

    RESULT BOOLEAN;
    V_DONE NUMBER;
      P_MESSAGE_NAME               VARCHAR2(100);
               P_INVOICE_AMOUNT             NUMBER;
               P_BASE_AMOUNT                NUMBER;
               P_TEMP_CANCELLED_AMOUNT      NUMBER;
               P_CANCELLED_BY               NUMBER;
               P_CANCELLED_AMOUNT           NUMBER;
               P_CANCELLED_DATE             DATE;
               P_LAST_UPDATE_DATE           DATE;
               P_ORIGINAL_PREPAYMENT_AMOUNT NUMBER;
               P_PAY_CURR_INVOICE_AMOUNT    NUMBER;
	       P_TOKEN			    VARCHAR2(100);
BEGIN
 
  -- CALL THE FUNCTION
  RESULT := AP_CANCEL_PKG.AP_CANCEL_SINGLE_INVOICE(P_INVOICE_ID => P_INVOICE_ID,
                                                   P_LAST_UPDATED_BY => 0,
                                                   P_LAST_UPDATE_LOGIN => 0,
                                                   P_ACCOUNTING_DATE => P_ACCOUNTING_DATE,
                                                   P_MESSAGE_NAME => P_MESSAGE_NAME,
                                                   P_INVOICE_AMOUNT => P_INVOICE_AMOUNT,
                                                   P_BASE_AMOUNT => P_BASE_AMOUNT,
                                                   P_TEMP_CANCELLED_AMOUNT => P_TEMP_CANCELLED_AMOUNT,
                                                   P_CANCELLED_BY => P_CANCELLED_BY,
                                                   P_CANCELLED_AMOUNT => P_CANCELLED_AMOUNT,
                                                   P_CANCELLED_DATE => P_CANCELLED_DATE,
                                                   P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
                                                   P_ORIGINAL_PREPAYMENT_AMOUNT => P_ORIGINAL_PREPAYMENT_AMOUNT,
                                                   P_PAY_CURR_INVOICE_AMOUNT => P_PAY_CURR_INVOICE_AMOUNT,
                                                   P_TOKEN => P_TOKEN,
                                                   P_CALLING_SEQUENCE => 'FPT_DDP_KQ_CANCEL_PUB_V1');
  -- CONVERT FALSE/TRUE/NULL TO 0/1/NULL 
 V_DONE := SYS.DIUTIL.BOOL_TO_INT(RESULT);
 IF RESULT = FALSE  THEN
    X_RETURN_STATUS    := 'E';
      X_MSG_COUNT        := 1;
      X_MSG_DATA         := SQLERRM;
 END IF;

        
EXCEPTION WHEN
  OTHERS THEN
    X_RETURN_STATUS    := 'E';
      X_MSG_COUNT        := 1;
      X_MSG_DATA         := SQLERRM;

END ;

procedure AP_inv_accounting(p_invoice_id    number) is

	ln_retcode   varchar2(100) default null;
	lv_error_buf varchar2(100) default null;
BEGIN
  --mo_global.init('SQLAP');
  --MO_GLOBAL.SET_POLICY_CONTEXT('S',P_ORG_ID);
	ap_drilldown_pub_pkg.invoice_online_accounting(p_invoice_id       => p_invoice_id,
																								 p_accounting_mode  => 'F',
																								 p_errbuf           => lv_error_buf,
																								 p_retcode          => ln_retcode,
																								 p_calling_sequence => 'invocie');
  
  commit; 
end;

Procedure AR_receipt_accounting(p_receipt_id    number) is
 v_legal_entity_id     number;
 v_org_id              number;
 v_SET_OF_BOOKS_ID     number;
 l_accounting_batch_id number;
 l_request_id          number;
 p_errbuf              varchar2(1000);
 p_retcode             varchar2(10);
 l_event_source_info   XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;

begin
  --mo_global.init('AR');
  --mo_global.set_policy_context('S', v_org_id);
    /*fnd_global.apps_initialize(user_id      => 0,
                               resp_id      => 20678,
                               resp_appl_id => 222);*/
                               
  select t.legal_entity_id, t.org_id, t.set_of_books_id
    into v_legal_entity_id, v_org_id, v_SET_OF_BOOKS_ID
    from ar_cash_receipts_all t
   where t.cash_receipt_id = p_receipt_id
     and rownum = 1;  
  
    l_event_source_info.source_application_id := 222;
    l_event_source_info.application_id        := 222;
    l_event_source_info.legal_entity_id       := v_legal_entity_id;
    l_event_source_info.ledger_id             := v_SET_OF_BOOKS_ID;
    l_event_source_info.entity_type_code      := 'RECEIPTS';
    l_event_source_info.transaction_number    := p_receipt_id; --RECEIPT_number  draft 8642357
    l_event_source_info.source_id_int_1       := p_receipt_id; --CASH_RECEIPT_ID  862478

  
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

Procedure AR_VOID_REC(p_cash_receipt_id   number,
                      p_org_id            number,
                      p_date              date,
                      p_comment           varchar2,
                      x_return_status     out varchar2,
                      x_msg_count         out number,
                      x_msg_data          out varchar2)is
  
BEGIN
  mo_global.init('AR');
  mo_global.set_policy_context('S',p_org_id);
  
   /* Invoking Receipt Reverse API */
  ar_receipt_api_pub.REVERSE(
                   p_api_version             =>  1.0
                  ,p_init_msg_list           =>  FND_API.G_FALSE
                  ,p_commit                  =>  FND_API.G_FALSE
                  ,p_validation_level        =>  FND_API.G_VALID_LEVEL_FULL
                  ,x_return_status           =>  x_return_status
                  ,x_msg_count               =>  x_msg_count
                  ,x_msg_data                =>  x_msg_data
                  ,p_cash_receipt_id         =>  p_cash_receipt_id
                  ,p_receipt_number          =>  NULL
                  ,p_reversal_category_code  =>  'REV'
                  ,p_reversal_category_name  =>  NULL
                  ,p_reversal_gl_date        =>  p_date
                  ,p_reversal_date           =>  p_date
                  ,p_reversal_reason_code    =>  'PAYMENT REVERSAL'
                  ,p_reversal_reason_name    =>  NULL
                  ,p_reversal_comments       =>  p_comment
                  ,p_called_from             =>  NULL
                  ,p_cancel_claims_flag      =>  'Y'
                  ,p_org_id                  =>  p_org_id);
                  
  IF x_return_status = 'S' THEN
     commit;
  ELSE
     x_return_status := 'E';
     x_msg_data      := 'Void Receipt is error.';
  END IF;
exception 
  when others then
    x_return_status := 'E';
    x_msg_data      := sqlerrm;
END;


PROCEDURE AP_INV_CANCEL(P_DDP_ID               IN VARCHAR2,
												P_KYQUY_CANCEL_INF     IN DDP_KYQUY_CANCEL_TBL,
												X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
												X_MSG_COUNT            OUT NOCOPY NUMBER,
												X_MSG_DATA             OUT NOCOPY VARCHAR2,
												X_DDP_REQUEST_CODE     OUT NOCOPY VARCHAR2) IS

	v_invoice_id      number;
	v_count           number;
	v_index           number := P_KYQUY_CANCEL_INF.first;
  v_date            date;
  v_org_id          number;
  v_accounting_date date;
begin
  --mo_global.init('SQLAP');                        
	x_return_status := 'S';
  
	--> check ddp_id in process	
  select count(1)
    into v_count
    from fpt_ddp_process
   where ddp_id = p_ddp_id
     and program = 'Kyquy_Cancel'
     and status = 'P';
	
	if nvl(v_count, 0) > 0 then
		x_return_status := 'PE';
		x_msg_count     := 1;
		x_msg_data      := 'The request with DDP_ID ' || p_ddp_id ||
											 ' is in processing!!!';
		return;
	end if;
	
  --> check ddp_id exists 
  select count(1)
    into v_count
    from fpt_ddp_process
   where ddp_id = p_ddp_id
     and program = 'Kyquy_Cancel'
     and status = 'S';
  
  if nvl(v_count, 0) > 0 then
    x_return_status := 'S';
    x_msg_count     := 1;
    x_msg_data      := 'Cancel Success!!!';
    return;
  end if;
  
	--> insert ddp_id
	insert into fpt_ddp_process
		(ddp_id, program, status, start_time)
	values
		(p_ddp_id, 'Kyquy_Cancel', 'P', sysdate);	
  commit;
  
	--> check data input
	WHILE v_index <= P_KYQUY_CANCEL_INF.LAST LOOP
	-- check invoice cancelable
		begin
			mo_global.init('SQLAP');
			mo_global.set_policy_context('S',
																	 P_KYQUY_CANCEL_INF(v_index).ORG_ID);
			fnd_global.apps_initialize(user_id      => 0,
																 resp_id      => 20639,
																 resp_appl_id => 200);
          --- check invoice_id
			if check_invoice(P_KYQUY_CANCEL_INF(v_index).INVOICE_ID) = false then
				x_msg_count        := 1;
				x_msg_data         := 'Invoice cancel error: Invoice_id not exsits';
				x_ddp_request_code := P_KYQUY_CANCEL_INF(v_index)
															.ddp_request_code;
				rollback;
				return;
			end if;
      
      -- check mo ky AP
      if check_period(P_KYQUY_CANCEL_INF(v_index).org_id, to_date(P_KYQUY_CANCEL_INF(v_index).VOID_DATE,'dd/mm/yyyy')) = -1 then
        x_msg_count        := 1;
				x_msg_data         := 'Invoice cancel error: AP period close';
				x_ddp_request_code := P_KYQUY_CANCEL_INF(v_index)
															.ddp_request_code;
				rollback;
				return;
		  end if;
			v_invoice_id := P_KYQUY_CANCEL_INF(v_index).invoice_id;/*get_invoice_id(P_KYQUY_CANCEL_INF(v_index)
																		 .INVOICE_NUMBER);*/
			/*if check_invoice_id(v_invoice_id,
													P_KYQUY_CANCEL_INF(v_index).ORG_ID) = false then
				x_msg_count        := 1;
				x_msg_data         := 'Invoice cancel error: Invoice_number or org_id not exsits';
				x_ddp_request_code := P_KYQUY_CANCEL_INF(v_index)
															.ddp_request_code;
				rollback;
				return;
			end if;*/
		
			AP_CHECK_CANCEL_INVOICE(P_invoice_id    => v_invoice_id,
														 X_RETURN_STATUS => X_RETURN_STATUS,
														 X_MSG_COUNT     => X_MSG_COUNT,
														 X_MSG_DATA      => X_MSG_DATA);
		
			IF X_RETURN_STATUS = 'E' THEN
			
				x_msg_count        := 1;
				x_msg_data         := 'Invoice cancel error: ' || X_MSG_DATA;
				x_ddp_request_code := P_KYQUY_CANCEL_INF(v_index)
															.ddp_request_code;
				rollback;
				return;
			end if;
		
    -- check receipt_id
    if check_receipt(P_KYQUY_CANCEL_INF(v_index).receipt_id) = false then
      x_msg_count        := 1;
				x_msg_data         := 'receipt_id not exsits';
				x_ddp_request_code := P_KYQUY_CANCEL_INF(v_index)
															.ddp_request_code;
				rollback;
				return;
        end if;
		end;
		
	
		<<STOP>>
		v_index := v_index + 1;
		exit when x_return_status = 'E';
	end loop;
  
  
  -->If error  then return
	if x_return_status = 'E' then	
    update fpt_ddp_process
		   set Status = 'E', end_time = sysdate
	   where ddp_id = p_ddp_id
		   and program = 'Kyquy_Cancel'
       and Status = 'P';
    commit;	
		return;
	end if;

	v_index := P_KYQUY_CANCEL_INF.first;
	WHILE v_index <= P_KYQUY_CANCEL_INF.LAST LOOP
		-- cancel invocie
		begin
			mo_global.init('SQLAP');
			mo_global.set_policy_context('S',
																	 P_KYQUY_CANCEL_INF(v_index).ORG_ID);
			fnd_global.apps_initialize(user_id      => 0,
																 resp_id      => 20639,
																 resp_appl_id => 200);
			v_invoice_id :=  P_KYQUY_CANCEL_INF(v_index).invoice_id; /*get_invoice_id(P_KYQUY_CANCEL_INF(v_index)
																		 .INVOICE_NUMBER);*/
		
			ap_cancel_invocie(p_invoice_id      => v_invoice_id,
												p_accounting_date => to_date(P_KYQUY_CANCEL_INF(v_index)
																										 .VOID_DATE,
																										 'dd/mm/yyyy'),
												x_return_status   => x_return_status,
												x_msg_count       => x_msg_count,
												x_msg_data        => x_msg_data);
		
		
		end;
    
   /* -->cancel invocie		
			--mo_global.init('SQLAP');
			mo_global.set_policy_context('S',P_KYQUY_CANCEL_INF(v_index).ORG_ID);			
                                 
			v_invoice_id := P_KYQUY_CANCEL_INF(v_index).INVOICE_ID;
      v_date       := to_date(P_KYQUY_CANCEL_INF(v_index).VOID_DATE,'dd/mm/yyyy');
		  v_org_id     := P_KYQUY_CANCEL_INF(v_index).org_id;
      
      select gl_date 
        into v_accounting_date
        from ap_invoices_all x
       where x.invoice_id = v_invoice_id
         and rownum = 1;
      -->Cancel Inv   
			ap_cancel_invocie(p_invoice_id      => v_invoice_id,
												p_accounting_date => v_accounting_date,
                        p_org_id          => v_org_id,
												x_return_status   => x_return_status,
												x_msg_count       => x_msg_count,
												x_msg_data        => x_msg_data);*/
		
			if nvl(x_return_status,'S') <> 'S' then
        x_return_status    := 'E';
        x_msg_count        := 1;
        x_msg_data         := 'Invoice cancel error: ' || X_MSG_DATA;
        x_ddp_request_code := P_KYQUY_CANCEL_INF(v_index).ddp_request_code;
        rollback;
        goto STOP1;
      end if;
      
      -->Void Rec
      v_date       := to_date(P_KYQUY_CANCEL_INF(v_index).VOID_DATE,'dd/mm/yyyy');
		  v_org_id     := P_KYQUY_CANCEL_INF(v_index).org_id;
      
      AR_VOID_REC(p_cash_receipt_id   => P_KYQUY_CANCEL_INF(v_index).Receipt_id,
                  p_org_id            => v_org_id,
                  p_date              => v_date,
                  p_comment           => P_KYQUY_CANCEL_INF(v_index).comments,
                  x_return_status     => x_return_status,
                  x_msg_count         => x_msg_count,
                  x_msg_data          => x_msg_data);
                  
      if nvl(x_return_status,'S') <> 'S' then
        x_msg_count        := 1;
        x_msg_data         := 'Receipt void error: ' || X_MSG_DATA;
        x_ddp_request_code := P_KYQUY_CANCEL_INF(v_index).ddp_request_code;
        goto STOP1;
      end if;
      -->create accounting invoice Final
			AP_inv_accounting(v_invoice_id);
		  AR_receipt_accounting(P_KYQUY_CANCEL_INF(v_index).Receipt_id);  
    
    <<STOP1>>
    Exit when x_return_status = 'E';
    v_index := v_index + 1;
	end loop;
  
  if x_return_status = 'E' then
    update fpt_ddp_process
		   set Status = 'E', end_time = sysdate
	   where ddp_id = p_ddp_id
		   and program = 'Kyquy_Cancel'
       and Status = 'P';
    commit;
    return;
  end if;
	--> update trang thai ddp_id
	update fpt_ddp_process
		 set Status = 'S', end_time = sysdate
	 where ddp_id = p_ddp_id
		 and program = 'Kyquy_Cancel'
     and Status = 'P';

	x_return_status := 'S';
	x_msg_count     := 1;
	x_msg_data      := 'Cancel Success!!!';

exception
	when others then		
		x_return_status := 'E';
		x_msg_count     := 1;
		x_msg_data      := sqlerrm;	
    
    update fpt_ddp_process
		   set Status = 'E', end_time = sysdate
	   where ddp_id = p_ddp_id
		   and program = 'Kyquy_Cancel'
       and Status = 'P';
    commit;
end ap_inv_cancel;

END FPT_DDP_KQ_CANCEL_PUB_V1;
/
