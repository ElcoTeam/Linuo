<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PLCConfig.aspx.cs" Inherits="LiNuoMes.BaseConfig.PLCConfig" %>

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
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    
     <script>
         var GoodsCode = "";
         var OPtype = "";           //操作类型: CHECK, EDIT
         var FMType = "MAINTAIN";   //form类型: MAINTAIN, SEND, 当初设想把PLC参数设定和参数派发做到一个界面里面, 迫于项目的时间压力只好分开完成.
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

             InitPage();
        });

        //加载表格
         function InitPage() {
             GoodsCode = request("GoodsCode");
             OPtype = request("OPtype");
             $("#GoodsCode").html(GoodsCode);
             $("#FormTitle").html("PLC参数维护");
             $("[PLC_PANEL]").remove();

             if (OPtype == "CHECK") {
                 $("#btn_OK").remove();
             }

             $.ajax({
                 url: "GetSetBaseConfig.ashx",
                 data: {
                     "Action": "MES_PLC_CONFIG_LIST",
                     "GoodsCode": GoodsCode 
                 },
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     initPLCContent(data);
                 },
                 error: function (msg) {
                     alert(msg.responseText);
                 }
             });
        }

        function initPLCContent(data) {
            for (i in data)
            {
                var trow;
                var PLC_ID = "PLC_" + data[i].ID;
                var strListContent = '<div PLC_PANEL style="margin-top:10px; overflow: hidden; border: 1px solid #65e8f5; background-color: #fff;">'
                                + '<table id="' + PLC_ID + '" border="0" style="width:100%">'
                                + '<tr style="background-color:ButtonFace"> '
                                + '<td class="formTitle" style="font-weight:bold; color:blueviolet; padding-left:10px;text-align:left;" colspan="6">'
                                + '[' + data[i].PLCCabinet + '.' + data[i].PLCCode + ']: ' + data[i].ProcessName + '-' + data[i].PLCName
                                + '</td>'
                                + '</tr>'
                                + '</table></div>';
                $("#areascontent").append(strListContent);
                var Parames = data[i].Parames;
                for (j in Parames) {
                    if (j % 3 == 0) {                                
                        trow = $("<tr></tr>");
                        $("#" + PLC_ID).append(trow);
                    }
                    var PARAME_ID = "PARAME_" + Parames[j].ID;
                    var tdTitle = $('<td class="formTitle">' + Parames[j].ParamDsca + '</td>');
                    var tdValue = $('<td><input id="' + PARAME_ID + '" type="text" class="form-control" value="' + Parames[j].ParamValue + '"</td>');
                    tdTitle.appendTo(trow);
                    tdValue.appendTo(trow);
                    if (Parames[j].OperateType == 'R' || OPtype == "CHECK") {
                        $("#" + PARAME_ID).attr("disabled", true);
                    }
                    else {
                        $("#" + PARAME_ID).bind("change", onParamChange);
                    }
                }
            }
            if (data.length == 0) {
                var strListContent = '<div style="margin-top:10px; overflow: hidden; border: 1px solid #e6e6e6; background-color: #fff;">'
                + '<table id="' + PLC_ID + '" border="0" style="width:100%">'
                + '<tr style="background-color:ButtonFace"> '
                + '<td class="formTitle" style="font-weight:bold; color:blueviolet; padding-left:10px;text-align:center;" >系统没有找到任何有关PLC数据!</td>'
                + '</tr>'
                + '</table>';
                $("#areascontent").append(strListContent);
            }
        }

        function onSaveParameters(ListJason) {
            var ListJason = GetUpdatedListJson();
            if (ListJason.length == 0) {
                alert("系统当下没有发现您有过更改动作.");
                return;
            }
            var ListJason = JSON.stringify(ListJason);

            $.ajax({
                url: "GetSetBaseConfig.ashx",
                data: {
                    "Action"   : "MES_PLC_CONFIG_EDIT",
                    "GoodsCode": GoodsCode,
                    "ListJson" : ListJason
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    if (data.result == "success") {
                        dialogMsg('保存成功!', 1);
                        InitPage();
                    }
                    else if (data.result == "failed") {
                        dialogMsg(data.msg, -1);
                    }
                    else {
                        dialogMsg(data.msg, -1);
                    }
                },
                error: function (msg) {
                    dialogMsg(msg.responseText, -1);
                }
            });
        }

        function GetUpdatedListJson() {
            var tmpList = [];
            var objlist = $("INPUT[OPEDIT]");
            $.each(objlist, function (index, obj) {
                tmpList.push({
                    "PARAM_ID": obj.id.substr(String("PARAME_").length),
                    "PARAM_VALUE": obj.value
                });
            });
            return tmpList;
        }

        function onbtn_OK(event) {
            if (OPtype == "CHECK") {
                onbtn_RT(null);
                return;
            }

            if (OPtype == "EDIT") {
                onSaveParameters();
            }
        }

        function onbtn_RT(event) {
            //window.location.href = "./GoodsConfig.aspx";
            window.history.back();
        }


        function onParamChange(event) {
            $(this).attr("OPEDIT", true);
            //console.log($(this).attr("OPEDIT"));
            //console.log($("#" + PARAME_ID).ID);
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;" id="FormTitle">PLC参数维护</strong></th>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table border="0" style="width:100%">
                                <tr>
                                    <th class="formTitle">产品物料编码：<span id="GoodsCode" class="formTitle">Goods Code</span></th>
                                    <td class="formValue" style="text-align:right;padding-left:10px">                                           
                                        <a id="btn_OK" class="btn btn-primary" onclick="onbtn_OK(event)"><i class="fa fa-floppy-o"></i>&nbsp;保存</a>  
                                        <a id="btn_RT" class="btn btn-primary" onclick="onbtn_RT(event)"><i class="fa fa-reply"></i>&nbsp;返回</a>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
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
           #form1{
               margin: 0px 0px 0px 150px;
           }
       } 
    </style>
    
</body>
</html>
