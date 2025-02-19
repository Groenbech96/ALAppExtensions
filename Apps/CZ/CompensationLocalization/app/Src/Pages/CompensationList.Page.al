page 31274 "Compensation List CZC"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Compensations';
    CardPageID = "Compensation Card CZC";
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Approve,Request Approval';
    SourceTable = "Compensation Header CZC";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Editable = false;
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the compensation.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies description for compensation.';
                }
                field("Company No."; Rec."Company No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of company.';
                }
                field("Company City"; Rec."Company City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of company.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user associated with the entry.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."User ID");
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of compensation.';
                }
                field("Balance (LCY)"; Rec."Balance (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ledger entries remaining amount. The amount is in the local currency.';
                    Visible = false;
                }
                field("Compensation Balance (LCY)"; Rec."Compensation Balance (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of amount compensation lines. The amount is in the local currency.';
                    Visible = false;
                }
                field("Compensation Value (LCY)"; Rec."Compensation Value (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of positive amount compensation lines. The amount is in the local currency.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(31272), "No." = field("No.");
            }
            part(WorkflowStatus; "Workflow Status FactBox")
            {
                ApplicationArea = All;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatus;
            }
            part(ApprovalFactBox; "Approval FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID" = const(31272), "Document No." = field("No.");
                Visible = false;
            }
            part(IncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
                Visible = false;
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("A&pprovals")
            {
                ApplicationArea = Suite;
                Caption = 'A&pprovals';
                Image = Approvals;
                ToolTip = 'Relations to the workflow.';

                trigger OnAction()
                var
                    ApprovalEntries: Page "Approval Entries";
                begin
                    ApprovalEntries.Setfilters(Database::"Compensation Header CZC", 0, Rec."No.");
                    ApprovalEntries.Run();
                end;
            }
            action(DocAttach)
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                end;
            }
        }
        area(Processing)
        {
            group(Posting)
            {
                Caption = 'P&osting';
                action("P&ost")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the compensation. The values are posted to the related accounts.';

                    trigger OnAction()
                    begin
                        Post(Codeunit::"Compensation - Post Yes/No CZC");
                    end;
                }
                action(PostAndPrint)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    ToolTip = 'Finalize and prepare to print the compensation. The values are posted to the related accounts.';

                    trigger OnAction()
                    begin
                        Post(Codeunit::"Compensation - Post Print CZC");
                    end;
                }
                action(PreviewPosting)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview Posting';
                    Image = ViewPostedOrder;
                    ShortCutKey = 'Ctrl+Alt+F9';
                    ToolTip = 'Review the result of the posting lines before the actual posting.';

                    trigger OnAction()
                    begin
                        ShowPreview();
                    end;
                }
            }
            group(RequestApproval)
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action(SendApprovalRequest)
                {
                    ApplicationArea = Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = not OpenApprovalEntriesExist;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Relations to the workflow.';

                    trigger OnAction()
                    begin
                        if CompensationApprovMgtCZC.CheckCompensationApprovalsWorkflowEnabled(Rec) then
                            CompensationApprovMgtCZC.OnSendCompensationForApprovalCZC(Rec);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = OpenApprovalEntriesExist;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Relations to the workflow.';

                    trigger OnAction()
                    begin
                        CompensationApprovMgtCZC.OnCancelCompensationApprovalRequestCZC(Rec);
                    end;
                }
            }
        }
        area(Reporting)
        {
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Report;
                PromotedOnly = true;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    CompensationHeaderCZC: Record "Compensation Header CZC";
                begin
                    CompensationHeaderCZC.Get(Rec."No.");
                    CurrPage.SetSelectionFilter(CompensationHeaderCZC);
                    CompensationHeaderCZC.PerformManualPrintRecords(true);
                end;
            }
            action(PrintToAttachment)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attach as PDF';
                Image = PrintAttachment;
                Promoted = true;
                PromotedCategory = Report;
                PromotedOnly = true;
                ToolTip = 'Create a PDF file and attach it to the document.';

                trigger OnAction()
                begin
                    Rec.PrintToDocumentAttachment();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.IncomingDocAttachFactBox.Page.LoadDataFromRecord(Rec);
        ShowWorkflowStatus := CurrPage.WorkflowStatus.Page.SetFilterOnWorkflowRecord(Rec.RecordId);
        SetControlAppearance();
    end;

    var
        CompensationApprovMgtCZC: Codeunit "Compensation Approv. Mgt. CZC";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        OpenApprovalEntriesExist: Boolean;
        ShowWorkflowStatus: Boolean;

    local procedure Post(PostingCodeunitID: Integer)
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        CompensationHeaderCZC := Rec;
        CompensationHeaderCZC.SetRecFilter();
        CompensationHeaderCZC.SendToPosting(PostingCodeunitID);
        CurrPage.Update(false);
    end;

    local procedure ShowPreview()
    var
        CompensationPostYesNoCZC: Codeunit "Compensation - Post Yes/No CZC";
    begin
        CompensationPostYesNoCZC.Preview(Rec);
    end;

    local procedure SetControlAppearance()
    begin
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
    end;
}
