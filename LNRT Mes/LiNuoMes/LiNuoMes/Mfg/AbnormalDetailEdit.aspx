<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AbnormalDetailEdit.aspx.cs" Inherits="LiNuoMes.Mfg.AbnormalDetailEdit" %>

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
    
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link href="../Content/scripts/plugins/icheck/skins/square/square.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/icheck/icheck.min.js"></script>
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
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
         var AbId = "";
         var AbnormalPoint = "";
         var OPtype   = "";
         var OPaction = "";
         var ReasonArray = new Array();

         $(function () {
                
                $('input').iCheck({
                    checkboxClass: 'icheckbox_square',
                    increaseArea: '20%'
                });

                AbId = request('AbId');
                OPtype = request('OPtype');

                if (AbId == undefined) {
                    AbId = 0;
                }

                if (OPtype == undefined) {
                    OPtype = "CHECK";
                }

                if (OPtype == "CHECK") {
                    OPaction = "MFG_WIP_DATA_ABNORMAL_DETAIL";
                }
                else if (OPtype == "EDIT") {
                    OPaction = "MFG_WIP_DATA_ABNORMAL_EDIT";
                }
                else if (OPtype == "ADD") {
                    OPaction = "MFG_WIP_DATA_ABNORMAL_ADD";
                }

                initAbPointContent();

                $("#AbnormalType2").on('ifToggled', function (event) {
                    if ($("#AbnormalType2").is(':checked')) {
                        $("#AbnormalType3").iCheck('uncheck');
                    }
                });

                $("#AbnormalType3").on('ifToggled', function (event) {
                    if ($("#AbnormalType3").is(':checked')) {
                        $("#AbnormalType2").iCheck('uncheck');
                    }
                });

                if (OPtype != "ADD") {
                    InitialPage(0);
               }
                
                setPermmit();
                
         });

         function setPermmit() {

             $(":input").attr("disabled", true);
             
             if (OPtype != "CHECK") {
                 $("[EDITFLG]").attr("disabled", false);
             }
             
             if (OPtype == "ADD") {
                 $("[ADDFLG]").attr("disabled", false);
             }
         }
         
         function InitialPage(nPoint) {
             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     "Action": "MFG_WIP_DATA_ABNORMAL_DETAIL",
                     "AbId": AbId,
                     "AbnormalPoint": nPoint
                 },
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     InitDataItems(JSON.parse(data));
                 },

                 error: function (msg) {
                     alert(msg.responseText);
                 }
             });
         }

         function InitDataItems(data) {

             if (data.AbnormalType == "2") {
                 $("#AbnormalType2").iCheck("check");
             }
             else if (data.AbnormalType == "3") {
                 $("#AbnormalType3").iCheck("check");
             }

             if (OPtype != "CHECK") {

                 // $("#AbnormalType2").iCheck("enable");
                 // $("#AbnormalType3").iCheck("enable");
                 /*
                 if (   data.AbnormalPoint == "1"
                     || data.AbnormalPoint == "2") {           //此处有歧义, 需求描述为: "第一、二个下线工位默认不选择，如选择，只允许选择其一"
                     // $("#AbnormalType3").iCheck("disable");  
                 }
                 else if (data.AbnormalPoint == "3") {         //此处有歧义, 需求描述为: "第三个下线工位固定为未完工，不可修改"
                     //$("#AbnormalType2").iCheck("disable");     
                     //$("#AbnormalType3").iCheck("disable");     
                     $("#AbnormalType3").iCheck("check");      //这项选中只是需求的字面意思, 其实实际是很不合理的.
                 }
                 */
             }

             $("#RFID").val(data.RFID);
             $("#WorkOrderNumber").val(data.WorkOrderNumber);
             $("#GoodsCode").val(data.GoodsCode);
             $("#AbnormalTime").val(data.AbnormalTime);
             $("#AbnormalUser").val(data.AbnormalUser);
             $("input:radio[name='AbnormalPoint'][value='"   + data.AbnormalPoint   + "']").iCheck("check");
             $("input:radio[name='AbnormalProduct'][value='" + data.AbnormalProduct + "']").iCheck("check");
         }
        
         function initAbPointContent() {
             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     "Action": "MFG_WIP_DATA_ABNORMAL_POINT"
                 },
                 type: "post",
                 async: false,
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     var strListContent = "";
                     for (i in data) {
                         strListContent +=
                               '<input ADDFLG="true" type="radio" name="AbnormalPoint" value ="' + data[i].ID + '" id="AbnormalPoint' + data[i].ID + '" class="form-control"/>'
                             + '<label for="AbnormalPoint' + data[i].ID + '" class="rTitle">' + data[i].DisplayValue + '</label>';
                     }
                     $("#tdAbnormalPoint").html(strListContent);

                     $("input:radio[name='AbnormalPoint']").iCheck({
                         radioClass: 'iradio_square',
                         increaseArea: '20%',
                     }); 

                     $("input:radio[name='AbnormalPoint']").on("ifToggled", function (event) {
                            $("#tdAbnormalReason").html("");
                            var nPoint = $("input:radio[name='AbnormalPoint']:checked").val();
                            initAbProuctContent(nPoint);
                            InitialPage(nPoint);
                     });

                     setPermmit();
                 },
                 error: function (msg) {
                     alert(msg.responseText);
                 }
             });
         }

         function initAbProuctContent(nPoint) {
             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     "Action": "MFG_WIP_DATA_ABNORMAL_PRODUCT",
                     "ABPOINTID": nPoint
                 },
                 type: "post",
                 async: false,
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     var strListContent = "";
                     for (i in data) {
                         strListContent +=
                               '<input EDITFLG="true" type="radio" name="AbnormalProduct" value ="' + data[i].ID + '" id="AbnormalProduct' + data[i].ID + '" class="form-control"/>'
                             + '<label for="AbnormalProduct' + data[i].ID + '" class="pTitle">' + data[i].DisplayValue + '</label>';
                     }
                     $("#tdAbnormalProduct").html(strListContent);
                   
                     $("input:radio[name='AbnormalProduct']").iCheck({
                        radioClass: 'iradio_square',
                        increaseArea: '20%'
                     });

                     $("input:radio[name='AbnormalProduct']").on("ifToggled", function (event) {
                            var nProduct = $("input:radio[name='AbnormalProduct']:checked").val();
                            initAbReasonContent(nProduct);                     
                     });

                     if (data.length == 1) {
                         $('#AbnormalProduct' + data[0].ID).iCheck("check");
                      // $('#AbnormalProduct' + data[0].ID).trigger("ifToggled");  //实践证明, 此语句可以不写, iCheck可以自动触发.
                     }

                     setPermmit();
                 },
                 error: function (msg) {
                     alert(msg.responseText);
                 }
             });
         }

         function initAbReasonContent(nProduct) {
             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     "Action": "MFG_WIP_DATA_ABNORMAL_REASON",
                     "ABPRODUCT": nProduct,
                     "AbId": AbId
                 },
                 type: "post",
                 async: false,
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     var strListContent = "";
                     ReasonArray.length = 0;
                     ReasonArray = data;
                     for (i in data) {
                         strListContent += '<li class="liTitle">' + data[i].DisplayValue + ': <input type="text" EDITFLG="true" id="AbnormalReason' + data[i].TemplateID + '"  style="width:30px" value="' + data[i].RecordValue + '"/>处</li>';
                     }
                     $("#tdAbnormalReason").html(strListContent);

                     setPermmit();

                 },
                 error: function (msg) {
                     alert(msg.responseText);
                 }
             });
         }

         function getAbnormalReasonJson() {
             var iCount = 0;
             for (i = 0; i < ReasonArray.length; i++) {
                 var obj = $('#AbnormalReason' + ReasonArray[i].TemplateID);
                 var data = obj.val();
                 data = data.trim();
                 obj.val(data);

                 if (data.length > 0) {
                     data = parseInt(data);
                     if (isNaN(data)) {
                         dialogMsg("请录入数字型数据!", -1);
                         obj.focus();
                         return -1;
                     }

                     if (data < 1) {
                         dialogMsg("请录入正整数数据!", -1);
                         obj.focus();
                         return -1;
                     }

                     ReasonArray[i].RecordValue = data;
                     iCount++;
                 }
                 else {
                     ReasonArray[i].RecordValue = 0;
                 }
             }
             return iCount;
         }

         function AcceptClick(grid) {
             
             if (OPtype == "CHECK")
             {
                 dialogClose();
                 return;
             }

             var RFID            = $("#RFID").val().toUpperCase().trim();
             var AbnormalPoint   = $("input[name='AbnormalPoint']:checked").val();
             var AbnormalProduct = $("input[name='AbnormalProduct']:checked").val();
             var AbnormalTime    = $("#AbnormalTime").val().trim();
             var AbnormalUser    = $("#AbnormalUser").val().trim();

             var JsonCount = getAbnormalReasonJson();

             if (JsonCount  == 0) {
                 dialogMsg("请录入下线原因!", -1);
                 return;
             }
             else if (JsonCount < 0) {
                 return;
             }

             $("#RFID").val(RFID);

             var AbnormalType = "1";

             if ($("#AbnormalType2").is(':checked')){
                 AbnormalType = "2";
             }

             if ($("#AbnormalType3").is(':checked')){
                 AbnormalType = "3";
             }

             if (AbnormalTime.length == 0) {
                 dialogMsg("请录入下线时间!", -1);
                 $("#AbnormalTime").focus();
                 return;
             }

             if (AbnormalUser.length == 0) {
                 dialogMsg("请录入下线人员!", -1);
                 $("#AbnormalUser").focus();
                 return;
             }

             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     "Action"            : OPaction,
                     "AbId"              : AbId,
                     "RFID"              : RFID,
                     "AbnormalPoint"     : AbnormalPoint,
                     "AbnormalProduct"   : AbnormalProduct,
                     "AbnormalType"      : AbnormalType,
                     "AbnormalTime"      : AbnormalTime,
                     "AbnormalUser"      : AbnormalUser,
                     "AbnormalReasonJson": JSON.stringify(ReasonArray)
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

         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }

    </script>
    <div style="margin-left: 10px; margin-top: 10px; margin-right: 10px;">
        <table class="form" style="margin-top:2px; padding:5px"  border="0"  >
            <tr>
                <td class="formTitle">下线工序:</td>
                <td colspan="3" id="tdAbnormalPoint"></td>
            </tr>
            <tr>
                <td class="formTitle">MES码:</td>
                <td colspan="3">
                    <input type="text" class="form-control" id="RFID" />
                </td>

            </tr>
            <tr>
                <td class="formTitle">订单编号:</td>
                <td>
                    <input type="text" class="form-control" id="WorkOrderNumber"/>
                </td>
                <td class="formTitle">产品物料编码:</td>
                <td>
                    <input type="text" class="form-control" id="GoodsCode"  />
                </td>
            </tr>
            <tr>
                <td class="formTitle">下线时间:</td>
                <td>
                    <input EDITFLG="true" type="text" id="AbnormalTime" style="width:180px" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm', readOnly:true})" class="Wdate timeselect"/>
                </td>
                <td class="formTitle">下线人员:</td>
                <td>
                    <input EDITFLG="true" type="text" class="form-control"  id="AbnormalUser"  />
                </td>
             </tr>
            <tr>
            <tr>
                <td class="formTitle">下线类型:</td>
                <td colspan="3">
                    <input EDITFLG="true" type="checkbox" id="AbnormalType2" value="2">
                    <label for="AbnormalType2" class="formTitle" style="font-weight:normal; color:blueviolet; text-align:left;" >报废</label>
                    <input EDITFLG="true" type="checkbox" id="AbnormalType3" value="3" >
                    <label for="AbnormalType3" class="formTitle" style="font-weight:normal; color:blueviolet; text-align:left;" >未完工</label>
               </td>
            </tr>
            <tr>
                <td class="formTitle">下线产品:</td>
                <td colspan="3" id="tdAbnormalProduct"></td>
            </tr>
            <tr>
                <td class="formTitle" style="vertical-align:top; text-align:left">下线原因:</td>
                <td colspan="3" >
                    <ul id="tdAbnormalReason"></ul>
                </td>
            </tr>
           
        </table>
    </div>
   <style>
     table td{padding:2px;}
    .formTitle {
        width:60px;
        font-size:9pt;
        padding:5px!important;
    }

    .rTitle {
        width:110px;
        font-size:9pt;
        font-weight:normal;
        color:blueviolet; 
        text-align:left;
        padding:5px!important;
    }

    .pTitle {
        width:68px;
        font-size:9pt;
        font-weight:normal;
        color:blueviolet; 
        text-align:left;
        padding:5px!important;
    }

    .liTitle {
        width:250px;
        font-size:9pt;
        padding-left:5px;
        padding-bottom:5px;
        font-weight:normal;
        text-align:left;
    }

    .formValue  {
        width:160px;
        font-size:9pt;
    }

    .form-control  {
        width:180px;
        font-size:9pt;
    }
  
    </style>
</body>
</html>

