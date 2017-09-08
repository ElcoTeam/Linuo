<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LineConfig.aspx.cs" Inherits="LiNuoMes.BaseConfig.LineConfig" %>

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
        $(function () {

            var n = 1;
            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height() - 106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#areascontent').height($(window).height() - 106);
                }, 200);
            });

            $.ajax({
                url: "GetSetBaseConfig.ashx",
                data: {
                    "ACTION": "MES_LINE_CONFIG_READ"
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    if (data.result == "success") {
                        $("#LineCode").val(data.data.LineCode);
                        $("#LineName").val(data.data.LineName);
                        $("#ShiftHours").val(data.data.ShiftHours);
                        $("#LineCapacity").val(data.data.LineCapacity);
                        $("#LineHeadCount").val(data.data.LineHeadCount);
                        $("#LineDsca").val(data.data.LineDsca);
                    }
                    else if (data.result == "failed") {
                        alert(data.msg);
                    }
                    else {
                        alert(data.msg);
                    }
                },
                error: function (msg) {
                    alert(msg.responseText);
                }
            });


        });

        function btn_cancel() {
            window.reload();                
        }

        function btn_ok() {

            var LineCode = $("#LineCode").val();
            var LineName = $("#LineName").val();
            var ShiftHours = $("#ShiftHours").val();
            var LineCapacity = $("#LineCapacity").val();
            var LineHeadCount = $("#LineHeadCount").val();
            var LineDsca = $("#LineDsca").val();

            if (LineCode == "" ||
                LineName == "" ||
                ShiftHours == "" ||
                LineCapacity == "" ||
                LineHeadCount == "" ||
                LineDsca == ""
                ) {
                alert('您录入的信息不全, 请仔细检查!');
                return;
            }

            $.ajax({
                url: "GetSetBaseConfig.ashx",
                data: {
                    "ACTION": "MES_LINE_CONFIG_SAVE",
                    "LineCode": LineCode,
                    "LineName": LineName,
                    "ShiftHours": ShiftHours,
                    "LineCapacity": LineCapacity,
                    "LineHeadCount": LineHeadCount,
                    "LineDsca": LineDsca
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    if (data.result == "success") {
                        alert('保存成功!');
                        window.reload();
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
       
    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body">
    <div id="ajax-loader" style="cursor: progress; position: fixed; top: -50%; left: -50%; width: 200%; height: 200%; background: #fff; z-index: 10000; overflow: hidden;">
        <img src="../Content/images/ajax-loader.gif" style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; margin: auto;" />
    </div>
    <!--nav-->
    <div class="navbar navbar-inverse navbar-fixed-top" id="nav"></div>
    <!--end nav-->
   
    <!--导航栏-->
    <div class="yn jz container-fluid nav-bgn m0" id="menu_wrap"></div>

    <!--主体-->
    <div id="areascontent" style="margin:50px 10px 5px 10px; margin-bottom: 0px; overflow: auto;">
        <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <table id="panelheading" border="0" style="width:100%">
                                <tr>
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">产线信息管理</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div>                        
                        <table border="0" style="float: none; width: 100%; border-collapse:separate; border-spacing:10px">
                               <tr>
                                   <td class="formTitle" style="width:33%">产线编号：</td>
                                   <td style="width:10px">
                                      <input type="text" class="form-control" id="LineCode" placeholder="产线编号">
                                   </td> 
                                   <td></td>
                               </tr>
                               <tr>
                                   <td class="formTitle">产线名称：</td>
                                   <td>
                                    <input type="text"  class="form-control"  id="LineName" placeholder="产线名称">
                                   </td>
                                   <td></td>
                               </tr>
                               <tr>
                                   <td class="formTitle">每日工时：</td>
                                   <td>
                                    <input type="text"  class="form-control"  id="ShiftHours" placeholder="每日工时">
                                   </td>
                                   <td class="formTitle" style="text-align:left">小时</td>
                               </tr>
                               <tr>
                                   <td class="formTitle">设计产能：</td>
                                   <td >
                                    <input class="form-control" type="text"  id="LineCapacity" placeholder="设计产能">
                                   </td>
                                   <td class="formTitle" style="text-align:left">台/天</td>
                               </tr>
                               <tr>
                                   <td class="formTitle">产线配员：</td>
                                   <td>
                                    <input  class="form-control" type="text"  id="LineHeadCount" placeholder="产线配员">
                                   </td>
                                   <td class="formTitle" style="text-align:left">人</td>
                               </tr>
                               <tr>
                                   <td class="formTitle">产线描述：</td>
                                   <td >
                                    <textarea class="form-control" rows="4" cols="20"  id="LineDsca" placeholder="产线描述"></textarea>
                                   </td>
                                   <td></td>
                               </tr>
                           </table>
                        </div>
                            <div class="control-group"  style="text-align: center;margin-top:10px">                        
                            <a id="lr-edit"   class="btn btn-primary" onclick="btn_ok()"><i class="fa fa-check"></i>&nbsp;确认</a>
                            <a id="lr-calcel" class="btn btn-default" onclick="btn_cancel()"><i class="fa fa-times"></i>&nbsp;取消</a>
                        </div>                        
                        <br>
                        <br>
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
               /*width:300px;*/
               font-weight:normal;
               text-align:right;
           } 
           .form-control {
               font-size:15px;
               width:400px;
          }
       } 
       @media screen and (min-width: 1400px) { 
           .formTitle {
               font-size:15px;
               /*width:300px;*/
               font-weight:normal;
               text-align:right;
           } 
           .form-control {
               font-size:15px;
               width:400px;
          }
       } 
        
    </style>
</body>
</html>
