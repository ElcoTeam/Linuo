<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquSecondLevelAdd.aspx.cs" Inherits="LiNuoMes.Equipment.EquSecondLevelAdd" %>
<html>
<head>
    <title></title>
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
    
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>

    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/plugins/validator/validator.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <link href="../css/zTreeStyle/metro.css" rel="stylesheet" />
    <script src="../js/jquery.ztree.all-3.5.min.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <link href="../css/void_autocomplete.css" rel="stylesheet" />
    <script src="../js/void_autocomplete.js"></script>
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
     <script>
         var equid = request('equid');
         $(function () {
             var id = '<%=Session["UserName"] %>';
             $("#PmOper").val(id);
             fnDate();

             //得到所选设备
             $("#DeviceCode").empty();
             var optionstring = "";
             $.ajax({
                 url: "EquSecondLevelAdd.aspx/GetSecondLevelDeviceInfo",
                 type: "post",
                 dataType: "json",
                 data: "{deviceid:'"+equid+"'}",
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     var data1 = eval('(' + data.d + ')');
                     var i = 0;
                     for (i in data1) {
                         optionstring += "<option value=\"" + data1[i].DeviceCode + "\" >" + data1[i].DeviceName.trim() + "</option>";

                     }
                     $("#DeviceCode").html("<option value=''>请选择...</option> " + optionstring);
                 },
                 error: function (msg) {
                     dialogMsg("数据访问异常", -1);
                 }
             });
         });

         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }

         //保存表单
         function AcceptClick(grid) {
             if (!$('#ruleinfo').Validform()) {
                 return false;
             }

             var PmOper = $("#PmOper").val();
             var PmDate = $("#PmDate").val();
             var DeviceCode = $("#DeviceCode").val();
             var MaintenceTime = $("#MaintenceTime").val();
             var PowerLine = $("#PowerLine").val();
             var GroundLead = $("#GroundLead").val();
             var ReplacePart = $("#ReplacePart").val();
             var ReplaceName = $("#ReplaceName").val();
             var ReplaceCount = $("#ReplaceCount").val();
             var InspectionProblem = $("#InspectionProblem").val();

             //保存
             $.ajax({
                 url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                 traditional: true,
                 data: {
                     Action: "AddSecondLevelProblem",
                     PmOper: PmOper,
                     PmDate: PmDate,
                     DeviceCode: DeviceCode,
                     MaintenceTime: MaintenceTime,
                     PowerLine: PowerLine,
                     GroundLead: GroundLead,
                     ReplacePart: ReplacePart,
                     ReplaceName: ReplaceName,
                     ReplaceCount: ReplaceCount,
                     InspectionProblem: InspectionProblem
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

         //登陆时间
         function fnDate() {
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
                     var seperator1 = "-";
                     
                     // 获取请求头里的时间戳
                     time = xhr.getResponseHeader("Date");
                     //console.log(xhr.getAllResponseHeaders())
                     curDate = new Date(time);
                     var month = curDate.getMonth() + 1;
                     var strDate = curDate.getDate();
                     if (month >= 1 && month <= 9) {
                         month = "0" + month;
                     }
                     if (strDate >= 0 && strDate <= 9) {
                         strDate = "0" + strDate;
                     }
                     var currentdate = curDate.getFullYear() + seperator1 + month + seperator1 + strDate;
                     $("#PmDate").val(currentdate);
                 }
             }
         }
    </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
            <table class="form" id="ruleinfo" style="margin-top:10px;">
                <tr>
                    <th class="formTitle">点检日期<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="PmDate" type="text" class="form-control" readonly/>
                    </td>
                    <th class="formTitle">保养人<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="PmOper" type="text" class="form-control"  readonly/>        
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">设备名称<font face="宋体">*</font></th>
                    <td class="formValue">
                        <select class="form-control" id="DeviceCode" isvalid="yes" checkexpession="NotNull">
                        </select>
                    </td>
                   <%-- <th class="formTitle">设备名称</th>
                    <td class="formValue">
                        <input id="DeviceName" type="text" class="form-control"  readonly/>        
                    </td>--%>
                </tr>
                <tr>
                    <th class="formTitle">保养工时</th>
                    <td class="formValue">
                         <input id="MaintenceTime" type="text" class="form-control" isvalid="yes" checkexpession="NumOrNull"/>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">电源线绝缘(&Omega;)<font face="宋体">*</font></th>
                    <td class="formValue">
                         <input id="PowerLine" type="text" class="form-control" isvalid="yes" checkexpession="Num"/>
                    </td>
                    <th class="formTitle">接地线(&Omega;)<font face="宋体">*</font></th>
                    <td class="formValue">
                         <input id="GroundLead" type="text" class="form-control" isvalid="yes" checkexpession="Num"/>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">更换配件部位</th>
                    <td class="formValue">
                         <input id="ReplacePart" type="text" class="form-control"/>
                    </td>
                    <th class="formTitle">更换配件名称</th>
                    <td class="formValue">
                         <input id="ReplaceName" type="text" class="form-control"/>
                    </td>
                </tr>
                 <tr>
                    <th class="formTitle">更换配件件数</th>
                    <td class="formValue">
                         <input id="ReplaceCount" type="text" class="form-control" isvalid="yes" checkexpession="PositiveNumOrNull"/>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        保养前存在问题
                    </th>
                    <td class="formValue" colspan="3">
                        <textarea id="InspectionProblem"  class="form-control" style="height: 150px;" ></textarea>
                    </td>
                </tr> 
                
            </table>
       </div>
   <style>
    .form .formTitle {
        width:100px;
        font-size:9pt;
    }
    .timeselect{
        width:193px;
        height:30px;
    }
     .problemcount{
        width: 30px; 
        border: none; 
        border-bottom: 1px solid #000;
        text-align: center;
    }
    </style>
</body>
</html>


