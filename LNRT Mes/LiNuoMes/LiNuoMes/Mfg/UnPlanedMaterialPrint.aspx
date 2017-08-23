<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UnPlanedMaterialPrint.aspx.cs" Inherits="LiNuoMes.Mfg.UnPlanedMaterialPrint" %>

<!DOCTYPE html>

<html>
<head>
    <title>力诺瑞特平板集热器</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="renderer" content="webkit">
    
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <link href="../css/learun-ui.css" rel="stylesheet" />
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/scripts/plugins/printTable/learun-report.css" rel="stylesheet" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../Content/scripts/plugins/printTable/jquery.printTable.js"></script>
    <script src="../js/jqGridExportToExcel.js"></script>
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
     <script>
         var actionname = request('actionname');
         var WorkOrderNumber = request('WorkOrderNumber');
         var WorkOrderVersion = request('WorkOrderVersion');
         var WHLocation = request('WHLocation');
         var WorkSite = request('WorkSite');

         $(function () {
             var panelwidth = $(window).width();
             var $gridTable = $('#gridTable');
            
             $gridTable.jqGrid({
                 url: "GetUnPlanedMaterial.ashx",
                 postData: { Action: "UnPlanedMaterialPrintInfo", WorkOrderNumber: WorkOrderNumber, WorkOrderVersion: WorkOrderVersion },
                 loadonce: true,
                 datatype: "json",
                 height: $(window).height() * 0.5,
                 colModel: [
                     //{ label: '序号', name: 'ID', index: 'ID', width: 50, align: 'center' },
                     { label: '物料编码', name: 'ItemNumber', index: 'ItemNumber', width: panelwidth * 0.25, align: 'center' },
                     { label: '物料描述', name: 'ItemDsca', index: 'ItemDsca', width: panelwidth * 0.35, align: 'left' },
                     { label: '单位', name: 'UOM', index: 'UOM', width: panelwidth * 0.1, align: 'center' },
                     { label: '申领数量', name: 'Qty', index: 'Qty', width: panelwidth * 0.1, align: 'center' },
                     { label: '实领数量', name: 'RealNum', index: 'RealNum', width: panelwidth * 0.1 },
                     { label: '保管签字', name: 'Sign', index: 'Sign', width: panelwidth * 0.1 },
                 ],
                 viewrecords: true,
                 rowNum: "10000",
                 //rownumbers: true,
                 //rownumWidth: 50,
                 shrinkToFit: false,
                 autowidth: true,
                 scrollrows: true,
                 gridview: true
             });
             //$gridTable.jqGrid('setLabel', 'rn', '序号', {
             //    'text-align': 'center'
             //});
             GetCurrentTime();
             InitalControl();
         });

         //初始化控件值
         function InitalControl() {
             $("#WorkOrderNumber").html(WorkOrderNumber);
             $("#WHLocation").html(WHLocation);
             $("#WorkSite").html(WorkSite);
             var id = '<%=Session["UserName"] %>';
             $("#LoginUser").html(id);
         }

         //打印导出
         function AcceptClick() {
             if(actionname==1) {
                 try {
                     //$("#gridPanel").jqprint();
                     $("#gridPanel").printTable(gridPanel);
                 } catch (e) {
                     dialogMsg("Exception thrown: " + e, -1);
                     //("Exception thrown: " + e);
                 }
             }
             else if (actionname == 2) {
                 var WorkOrderNumber = $("#WorkOrderNumber").text();
                 var WHLocation = $("#WHLocation").text();
                 var UnPlanedNumber = $("#UnPlanedNumber").text();
                 var WorkSite = $("#WorkSite").text();
                 var LoginUser = $("#LoginUser").text();
                 var CurrentTime = $("#CurrentTime").text();
                 ExportJQGridDataToExcel('#gridTable', '计划外领料单'+WorkOrderNumber,WorkOrderNumber, WHLocation, UnPlanedNumber, WorkSite, LoginUser, CurrentTime);
             }
         }

         function GetCurrentTime() {
             var xhr = null;
             if (window.XMLHttpRequest) {
                 xhr = new window.XMLHttpRequest();
             } else { // ie
                 xhr = new ActiveObject("Microsoft")
             }
             // 通过get的方式请求当前文件
             xhr.open("get", "/");
             xhr.send(null);
             // 监听请求状态变化
             xhr.onreadystatechange = function () {
                 var time = null,
                     curDate = null;
                 if (xhr.readyState === 2) {
                     // 获取请求头里的时间戳
                     time = xhr.getResponseHeader("Date");
                     curDate = new Date(time);
                     var seperator1 = "-";
                     var seperator2 = ":";
                     var month = curDate.getMonth() + 1;
                     var strDate = curDate.getDate();
                     if (month >= 1 && month <= 9) {
                         month = "0" + month;
                     }
                     if (strDate >= 0 && strDate <= 9) {
                         strDate = "0" + strDate;
                     }
                     var currentdate = curDate.getFullYear() + seperator1 + month + seperator1 + strDate
                             + " " + curDate.getHours() + seperator2 + curDate.getMinutes();
                     $('#CurrentTime').text(currentdate);
                 }
             }
         }

    </script>
       
        <div class="ui-report"> 
        <div class="gridPanel" id="gridPanel" >
             <div class="printArea">
                     <div class="grid-title">
                          <h1 style="text-align:center;">力诺瑞特制造工厂</h1> 
                          <h3 style="text-align:center;">计划外领料单</h3> 
                     </div>  
                     <div class="grid-subtitle">
                           <table class="form" id="ruleinfo" style="margin-top:10px;">
                                <tr>
                                    <th class="formTitle">生产订单号：</th>
                                    <td class="formValue">
                                        <label id="WorkOrderNumber"></label>
                                    </td>
                                    <th class="formTitle">仓库：</th>
                                    <td class="formValue">
                                        <label id="WHLocation"></label>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">计划外领料单号：</th>
                                    <td class="formValue">
                                        <label id="UnPlanedNumber"></label>
                                    </td>
                                    <th class="formTitle">工作中心：</th>
                                    <td class="formValue">
                                        <label id="WorkSite"></label>
                                    </td>
                                </tr>
                           </table>
                     </div>                     
                     <table id="gridTable"></table> 
                     
             </div>
             <div class="printArea">       
                    <table class="form"  id="ruleinfo1" style="margin-top:10px;">
                       <tr>
                           <th class="formTitle">车间班组长：</th>
                           <%--<td class="formValue">
                               <label id="Leader" style="width: 50px;" />
                           </td>--%>
                           <th class="formTitle">领料人：</th>
                           <%--<td class="formValue">
                               <label id="Leader1" style="width: 50px;" />
                           </td>--%>
                           <th class="formTitle">制单人：</th>
                           <td class="formValue" style="width:50px;">
                               <label id="LoginUser" style="width: 80px;"></label>
                           </td>
                           <th class="formTitle">打印时间：</th>
                           <td class="formValue">
                               <label id="CurrentTime" />
                           </td>
                       </tr>
                    </table> 
              </div>                        
        </div>
        </div> 

    <style>
    .form .formTitle {
        /*width:100px;*/
        font-size:13pt;
    }
    </style>
</body>
</html>


