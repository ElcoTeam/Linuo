<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductRepairDetailEdit.aspx.cs" Inherits="LiNuoMes.Mfg.ProductRepairDetailEdit" %>

<!DOCTYPE html>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
       <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="renderer" content="webkit">
    
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    <script type="text/javascript" src="../js/m.js" charset="gbk"></script>
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link href="../Content/scripts/plugins/icheck/skins/square/square.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/icheck/icheck.min.js"></script>
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="../css/learun-ui.css" rel="stylesheet" />--%>
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="http://www.jq22.com/favicon.ico" />
    <link href="../Content/styles/learun-ui.css?v=xGgPBYcCVZtMx26lXm_bETZOl5nvwnNwIiq-fpPtywo1" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>

    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/plugins/validator/validator.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <script src="../Content/scripts/plugins/validator/validator.js"></script>
    <link href="../css/zTreeStyle/metro.css" rel="stylesheet" />
    <script src="../js/jquery.ztree.all-3.5.min.js"></script>
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
     <script>
         var actionname = request('actionname');         var equid = request('equid');
         var OPaction = "";
         $(function () {
             if (actionname == 1)
             {
                 $("#RepairTime").attr("disabled", "disabled");
                 $("#RepairUser").attr("disabled", "disabled");
                 $("#RepairComment").attr("disabled", "disabled");
             }
             if(actionname == 2)
             {
                 OPaction = "ProductRepair_Repair";
             }
             if (actionname == 3) {
                 OPaction = "ProductRepair_Edit";
             }
             InitialPage();
         });

         //初始化控件值
         function InitialPage()
         {
             if (actionname == 1 || actionname == 3)
             {
                 $.ajax({
                     url: "../Mfg/GetProductRepair.ashx",
                     data: {
                         "Action": "ProductRepair_Detail",
                         "EquID": equid
                     },
                     type: "post",
                     datatype: "json",
                     success: function (data) {
                         data = JSON.parse(data);
                         $("#RFID").val(data.RFID);
                         $("#WorkOrderNumber").val(data.WorkOrderNumber);
                         $("#GoodsCode").val(data.GoodsCode);
                         $("#AbnormalPoint").val(data.AbnormalPoint);
                         $("#AbnormalTime").val(data.AbnormalTime);
                         $("#AbnormalUser").val(data.AbnormalUser);
                         $("#AbnormalReason").val(data.AbnormalReason);
                         $("#RepairTime").val(data.RepairTime);
                         $("#RepairUser").val(data.RepairUser);
                         $("#RepairComment").val(data.RepairComment);
                         if (data.AbnormalType == '1') {
                             $("#AbnormalType").val('补修');
                         }
                         else if (data.AbnormalType == '3') {
                             $("#AbnormalType").val('未完工');
                         }
                         Loading(false);
                     }, beforeSend: function () {
                         Loading(true);
                     }
                 });
             }
             
             if( actionname==2)
             {
                 $.ajax({
                     url: "../Mfg/GetProductRepair.ashx",
                     data: {
                         "Action": "ProductRepair_Detail",
                         "EquID": equid
                     },
                     type: "post",
                     datatype: "json",
                     success: function (data) {
                         data = JSON.parse(data);
                         $("#RFID").val(data.RFID);
                         $("#WorkOrderNumber").val(data.WorkOrderNumber);
                         $("#GoodsCode").val(data.GoodsCode);
                         $("#AbnormalPoint").val(data.AbnormalPoint);
                         $("#AbnormalTime").val(data.AbnormalTime);
                         $("#AbnormalUser").val(data.AbnormalUser);
                         $("#AbnormalReason").val(data.AbnormalReason);
                         
                         if (data.AbnormalType == '1') {
                             $("#AbnormalType").val('补修');
                         }
                         else if (data.AbnormalType == '3') {
                             $("#AbnormalType").val('未完工');
                         }
                         Loading(false);
                     }, beforeSend: function () {
                         Loading(true);
                     }
                 });
                 var id = '<%=Session["UserName"] %>';
                 $("#RepairUser").val(id);
                 GetCurrentTime();
             }
         }

         //保存表单
         function AcceptClick(grid)
         {
             var RepairTime = $("#RepairTime").val();
             var RepairUser = $("#RepairUser").val();
             var RepairComment = $("#RepairComment").val().trim();
             
             $.ajax({
                 url: "GetProductRepair.ashx",
                 data: {
                     "Action": OPaction,
                     "EquID": equid,
                     "RepairTime": RepairTime,
                     "RepairUser": RepairUser,
                     "RepairComment": RepairComment
                 },
                 async: true,
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     Loading(false);
                     data = JSON.parse(data);
                     if (data.result == "success") {
                         dialogMsg("保存成功", 1);
                         dialogClose();
                         grid.trigger("reloadGrid");
                     }
                     else if (data.result == "failed") {
                         dialogMsg(data.msg, -1);
                     }
                 },
                 error: function (XMLHttpRequest, textStatus, errorThrown) {
                     Loading(false);
                     dialogMsg(errorThrown, -1);
                 },
                 beforeSend: function () {
                     Loading(true, "正在保存数据");
                 },
                 complete: function () {
                     Loading(false);
                 }
             });
             
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
                             + " " + curDate.getHours() + seperator2 + curDate.getMinutes() + seperator2 + curDate.getMilliseconds();
                     $('#RepairTime').val(currentdate);
                 }
             }
         }

         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }

    </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
            <table class="form" id="ruleinfo" style="margin-top:10px;">
                <tr>
                    <th class="formTitle">MES码:</th>
                    <td class="formValue">
                       <input type="text" class="form-control" id="RFID" disabled/>
                    </td>
                    <th class="formTitle">设备名称:</th>
                    <td class="formValue">
                       <input type="text" class="form-control" id="WorkOrderNumber" disabled/>
                    </td>

                </tr>
                <tr>
                    <th class="formTitle">产品物料编码:</th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="GoodsCode" disabled/>
                    </td>
                    <th class="formTitle">下线工序:</th>
                    <td class="formValue">
                        <select class="form-control" id="AbnormalPoint" disabled>
                            <option value ="1">下线点1</option>
                            <option value ="2">下线点2</option>
                            <option value ="3">下线点3</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">下线类型:</th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="AbnormalType" disabled/> 
                    </td>
                    <td class="formTitle">下线时间:</td>
                    <td class="formValue">
                        <input type="text" id="AbnormalTime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:ss', readOnly:true})" class=" form-control Wdate timeselect" disabled/>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">下线人员:</th>
                    <td class="formValue">
                        <input  type="text" class="form-control"  id="AbnormalUser" disabled  />
                    </td>
                </tr>
                <tr>
                    <th class="formTitle" style="vertical-align:top">下线原因:</th>
                    <td class="formValue" colspan="3">
                        <textarea  id="AbnormalReason" class="form-control"  style="height: 150px;" disabled></textarea>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">补修时间:</th>
                    <td class="formValue">
                        <input type="text" id="RepairTime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:ss', readOnly:true})" class=" form-control Wdate timeselect" isvalid="yes" checkexpession="NotNull"/> 
                    </td>
                    <td class="formTitle">补修人员:</td>
                    <td class="formValue">
                        <input type="text" id="RepairUser" class="form-control" isvalid="yes" checkexpession="NotNull"/>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle" style="vertical-align:top">补修信息:</th>
                    <td class="formValue" colspan="3">
                        <textarea  id="RepairComment" class="form-control"  style="height: 150px;"></textarea>
                    </td>
                </tr>
            </table>
    </div>
   <style>
     .form .formTitle {
        width:100px;
        font-size:9pt;
    }
  
    </style>
</body>
</html>


