<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PlcSendOperate.aspx.cs" Inherits="LiNuoMes.Mfg.PlcSendOperate" %>

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
    <link href="../Content/scripts/plugins/icheck/skins/square/square.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/icheck/icheck.min.js"></script>
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <link href="../css/learun-ui.css" rel="stylesheet" />
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    
    <script src="../BaseConfig/GetSetBaseConfig.js"></script>
    <script>
        var GoodsCode = "";
        var WorkOrderNumber = "";
        var WorkOrderVersion = "";
        var ProcessCode = "";
        var BatchNo = "";
        var ParamesCount = 0;
        var timerID;
        var timeCount = 0;
        var Display_Refresh_TopCount = 60;
        $(function () {
             var n = 1;
             if ($('#areascontent').height() > $(window).height() - 20) {
                 $('#areascontent').css("margin-right", "0px");
             }
             $('#areascontent').height($(window).height()-106);
             var areaheight = $("#areascontent").height();
             $(window).resize(function (e) {
                 window.setTimeout(function () {
                     $('#areascontent').height($(window).height()-106);
                 }, 200);
             });

             g_getSetParam("PlayPause", "", "READ", onPausePlay);
             InitPage();

        });

        function onPausePlay(data) {
            if (data == "PLAY") {
                $("#btn_SD").attr("disabled", false);
            }
        }


        function InitPage() {
            GoodsCode = request("GoodsCode");
            WorkOrderNumber = request("WorkOrderNumber");
            WorkOrderVersion = request("WorkOrderVersion");
            ProcessCode = request("ProcessCode");
            $("#GoodsCode").html("产品物料编码:" + GoodsCode);
         // $("#ProcessCode").html("工序编号:" + ProcessCode)
            $("[PLC_PANEL]").remove();

            $.ajax({
                url: "..\\BaseConfig\\GetSetBaseConfig.ashx",
                data: {
                    "Action": "MES_PLC_CONFIG_LIST",
                    "GoodsCode": GoodsCode,
                    "SenderType": "VS"
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    initPLCContent(data);

                    $('input').iCheck({
                        checkboxClass: 'icheckbox_square',
                        radioClass: 'iradio_square',
                        increaseArea: '20%'
                    });

                    $('#CHK_ALL').on('ifToggled', function (event) {
                        if ($("#CHK_ALL").is(':checked')) {
                            $("[CHKPLC]:enabled").iCheck('check');
                        }
                        else {
                            $("[CHKPLC]:enabled").iCheck('uncheck');
                        }
                    });

                    $("[TBL_PARAME_DETAIL]").attr("hidden", "true");
                },
                error: function (msg) {
                    alert(msg.responseText);
                }
            });
        }

        function setTipColorTip(tipObj, tipColor, tipValue) {
            $(tipObj).html("<span class='formTitle' style='color:" + tipColor + "'>" + tipValue + "</span>");
        }

        function setPanelColor(pnlId, pnlColor) {
            $("#PNL_" + pnlId).addClass("panel-color-" + pnlColor);
            $("#PNL_" + pnlId + " input").addClass("panel-color-" + pnlColor);
        }

        function setParamColor(Parames, parColor) { 
            for (j = 0; j < Parames.length; j++) {
                if (Parames[j].StatusValue == "-2") {
                    $("#PARAME_" + Parames[j].ID).addClass("panel-color-" + parColor);
                }
            }
        }

        function onSD(event) {
            var ListJson = GetSendListJson();
            if (ListJson.PlcIdList.length == 0) {
                alert("没有发现您有选中需要派发的PLC设备.");
                return;
            }
            var tipObj = ListJson.tipObj;
            var chkObj = ListJson.chkObj;
            var PlcIdList = JSON.stringify(ListJson.PlcIdList);

            window.clearInterval(timerID);
            $.ajax({
                url: "..\\BaseConfig\\GetSetBaseConfig.ashx",
                data: {
                    "Action": "MES_PLC_PARAMETERS_SEND",
                    "ListJson": PlcIdList,
                    "WorkOrderNumber": WorkOrderNumber,
                    "WorkOrderVersion": WorkOrderVersion,
                    "SenderType": "VS"
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    if (data.result == "success") {
                        setTipColorTip(tipObj, "blue", "指令已发出");
                        $(chkObj).iCheck('disable');
                        $("#CHK_ALL").iCheck('disable');
                        $('#btn_SD').attr("disabled", true);
                        ParamesCount = data.ParamesCount;
                        BatchNo = data.BatchNo;
                        dialogMsg("派发指令发送成功, 此批次共发送参数: " + ParamesCount + " 条.", 1);
                        timeCount = Display_Refresh_TopCount;
                        timerID = window.setInterval(refreshStatus, 1 * 1000 );
                    }
                    else {
                        alert(data.msg);
                    }
                },
                error: function (msg) {
                    alert(msg.responseText);
                }
            });
        }

        function getSendResult() {
            $.ajax({
                url: "..\\BaseConfig\\GetSetBaseConfig.ashx",
                data: {
                    "Action": "MES_PLC_PARAMETERS_SEND_STATUS",
                    "BatchNo": BatchNo
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    if (data.result == "success") {
                        var PlcList = data.PlcList;
                        var completeCount = 0;
                        for (i = 0; i < PlcList.length; i++) {
                            if      (PlcList[i].StatusValue == "0") { //等待派发中...
                                setTipColorTip("#TIP_" + PlcList[i].ID, "blue", PlcList[i].StatusTip);
                            }
                            else if (PlcList[i].StatusValue == "1") { //正在派发中...
                                setTipColorTip("#TIP_" + PlcList[i].ID, "blue", PlcList[i].StatusTip);
                            }
                            else if (PlcList[i].StatusValue == "2") { //派发成功
                                setTipColorTip("#TIP_" + PlcList[i].ID, "green", PlcList[i].StatusTip);
                                setPanelColor(PlcList[i].ID, "green");
                                completeCount++;
                            }
                            else if (PlcList[i].StatusValue == "-2") {//派发失败
                                setTipColorTip("#TIP_" + PlcList[i].ID, "red", PlcList[i].StatusTip);

                                //如果有派发失败的情况发生, 则会把详细数据都显示出来, 便于设定某项具体参数颜色变色.
                                if ($("#TTL_" + PlcList[i].ID).attr("hidden")) {
                                    $("#TTL_" + PlcList[i].ID).removeAttr("hidden");
                                }
                                setParamColor(PlcList[i].Parames, "red");  //设定某个具体参数背景色变为红色.
                                $("#CHK_" + PlcList[i].ID).iCheck('enable');
                                completeCount++;
                            }
                            else  {
                                setTipColorTip("#TIP_" + PlcList[i].ID, "yellow", "获取状态中...");
                            }
                        }
                        if (completeCount == PlcList.length) {
                            stopMonitor();
                        }
                    }
                    else {
                        alert(data.msg);
                    }
                },
                error: function (msg) {
                    alert(msg.responseText);
                }
            });

            return;
        }

        function refreshStatus() {
            $("#TimerTip").text(timeCount);
            if (timeCount == 0) {
                timeCount = Display_Refresh_TopCount;
                dialogMsg("千万不要离开此页面, 系统并没有死掉!!!<br> "
                    + "请您检查硬件设备或者服务器上的监控程序是否正常,<br>"
                    + "这边会一直保持监视状态, 最终会明确提示给您成功与否!!"
                    + ""
                    , -1);
            }
            if (timeCount % 5 == 0) {
                getSendResult();
            }
            timeCount--;
        }

        function stopMonitor() {
            $('#btn_SD').attr("disabled", false);
            $("#CHK_ALL").iCheck('enable');
            $("#TimerTip").text("");
            window.clearInterval(timerID);
        }

        function initPLCContent(data) {
            for (i in data)
            {
                var trow;
                var PNL_ID = "PNL_" + data[i].ID;
                var TBL_ID = "TBL_" + data[i].ID;
                var CHK_ID = "CHK_" + data[i].ID;
                var TIP_ID = "TIP_" + data[i].ID;
                var TTL_ID = "TTL_" + data[i].ID;
                var strListContent =
                      '<div PLC_PANEL id="' + PNL_ID + '" style="margin-top:10px; overflow: hidden; border: 1px solid #65e8f5; background-color: #FFF;">'
                    + '<table  id="' + TTL_ID + '" border="0" style="width:100%" onclick="onTTL(\'' + TBL_ID + '\')">'
                    + '<tr style="background-color:whitesmoke"> '
                    + '<td class="formTitle" style="padding-left:10px;text-align:left;width:70%">'
                    + '<input CHKPLC type="checkbox" id="' + CHK_ID + '" value="' + data[i].ID + '">'
                    + '<label for="' + CHK_ID + '"class="formTitle" style="font-weight:bold; color:blueviolet; padding-left:10px; text-align:left" >'
                    + '[' + data[i].PLCCabinet + '.' + data[i].PLCCode + ']: ' + data[i].ProcessName + '-' + data[i].PLCName
                    + '</label>'
                    + '</td>'
                    + '<td  class="formTitle" style="font-weight:normal;color:blueviolet; padding-right:10px;">'
                    + '派发状态:'
                    + '<label id="' + TIP_ID + '" style="padding-left:5px; font-weight:bold"><span class="formTitle">无</span>'
                    + '</label>'
                    + '</td>'
                    + '</tr>'
                    + '</table>'
                    + '<table TBL_PARAME_DETAIL=true id="' + TBL_ID + '" border="0" style="width:100%">'
                    + '</table>'
                    + '</div>';
                $("#areascontent").append(strListContent);
                var Parames = data[i].Parames;
                for (j in Parames) {
                    if (j % 3 == 0) {                                
                        trow = $("<tr></tr>");
                        $("#" + TBL_ID).append(trow);
                    }
                    var PARAME_ID = "PARAME_" + Parames[j].ID;
                    var tdTitle = $('<td class="formTitle">' + Parames[j].ParamDsca + '</td>');
                    var tdValue = $('<td><input id="' + PARAME_ID + '" type="text" class="form-control" value="' + Parames[j].ParamValue + '"></td>');
                    tdTitle.appendTo(trow);
                    tdValue.appendTo(trow);
                    $("#" + PARAME_ID).attr("readonly", true);
                }
                if (Parames.length % 3 > 0) {
                    for (j = 0; j < 3 - Parames.length % 3; j++) {
                        var tdTitle = $('<td class="formTitle">&nbsp;</td>');
                        var tdValue = $('<td class="form-control" style="display:none">&nbsp;</td>');
                        tdTitle.appendTo(trow);
                        tdValue.appendTo(trow);
                    }
                }
            }
            if (data.length == 0) {
                var strListContent =
                      '<div style="margin-top:10px; overflow: hidden; border: 1px solid #e6e6e6; background-color: #fff;">'
                    + '<table id="' + TBL_ID + '" border="0" style="width:100%">'
                    + '<tr style="background-color:ButtonFace"> '
                    + '<td class="formTitle" style="font-weight:bold; color:blueviolet; padding-left:10px;text-align:center;" >系统没有找到任何有关PLC数据!</td>'
                    + '</tr>'
                    + '</table>'
                    + '</div>';
                $("#areascontent").append(strListContent);
            }
        }

        function GetSendListJson() {
            var tmpList = { PlcIdList: [], tipObj: "" , chkObj: ""};
            var strSpliter = "";
            $("[CHKPLC]").each(function () {
                if (! $(this).is(":disabled")) {
                    if ($(this).is(":checked")) {
                        tmpList.PlcIdList.push({
                            "PLCID": $(this).attr("value")
                        });
                        tmpList.tipObj += strSpliter + "#TIP_" + $(this).attr("value");
                        tmpList.chkObj += strSpliter + "#CHK_" + $(this).attr("value");
                        strSpliter = ",";
                    }
                }
            });
            return tmpList;
        }

        function onRT(event) {
            window.history.back();
        }

        function onTTL(obj) {
            if ($("#" + obj).attr("hidden")) {
                $("#" + obj).removeAttr("hidden");
            }
            else {
                $("#" + obj).attr("hidden", "true");
            }
        }

        function request(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }


    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body1" class="body">

    <!--nav-->
    <div class="navbar navbar-inverse navbar-fixed-top" id="nav"></div>
    <!--end nav-->
   
    <!--导航栏-->
    <div class="yn jz container-fluid nav-bgn m0" id="menu_wrap"></div>

    <!--主体-->
    <div id="areascontent" style="margin:50px 10px 15px 10px; margin-bottom: 0px; overflow: auto;">
        <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <table id="panelheading" border="0" style="width:100%">
                                <tr>
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;" id="FormTitle">PLC参数派发</strong></th>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table border="0" style="width:100%">
                                <tr>
                                    <td><span id="GoodsCode" class="formTitle"></span></td>                                        
                                    <td><span id="ProcessCode" class="formTitle"></span></td>
                                    <td><span id="TimerTip" class="formTitle"></span></td>
                                    <td style="text-align:right;margin-right:20px">                                          
                                        <a id="btn_SD" class="btn btn-primary" onclick="onSD(event)"><i class="fa fa-bars"></i>派发</a>  
                                        <a id="btn_RT" class="btn btn-primary" onclick="onRT(event)"><i class="fa fa-reply"></i>返回</a>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div style="margin-top:5px; overflow: hidden; border: 1px solid #e6e6e6; background-color: #FAFAFA;">
            <table border="0" style="width:100%">
                <tr> 
                    <td class="formTitle" style=" padding-left:10px;text-align:left;" >
                        <input type="checkbox" id="CHK_ALL">
                        <label class="formTitle" for="CHK_ALL" style="font-weight:bold; color:red; padding-left:0px; text-align:left;">全选</label>
                    </td>
                </tr>
            </table>
        </div>
    </div>

    <style>
        *{
            font-size:15px; 
        }
      
        @media screen and (max-width: 1400px) { 
           .formTitle {
               font-size:15px;
               width:400px;
               height: 30px;
               line-height: 40px;
               text-align:right;
           } 
           .form-control {
               font-size:15px;
               width:160px;
               height:30px;
               margin-left:5px;
               margin-right:5px;
           }

           .panel-color-red {
               background-color: #ff3333 !important;            
            }
           .panel-color-gray {
               background-color: #c9c9c9 !important;            
            }
           .panel-color-green {
               background-color: #33ff33 !important;            
            }

           .aa{
               width:200px;
               height:30px;
           }
           #form1{
               margin-left:0px;
           }
       } 
        @media screen and (min-width: 1400px) { 
          .formTitle {
              font-size:15px;
              width:400px;
              height: 30px;
              line-height: 40px;
              text-align:right;
          } 
          .form-control {
               font-size:15px;
               width:160px;
               height:30px;
               margin-left:5px;
               margin-right:5px;
           }

           .panel-color-red {
               background-color: #ff3333 !important;            
            }
           .panel-color-gray {
               background-color: #c9c9c9 !important;            
            }
           .panel-color-green {
               background-color: #33ff33 !important;            
            }

           #form1{
               margin: 0px;
           }
       } 
    </style>
    
</body>
</html>
