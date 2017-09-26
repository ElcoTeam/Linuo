<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialPullMonitorTrig.aspx.cs" Inherits="LiNuoMes.Mfg.MaterialPullMonitorTrig" %>

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
    
    <script src="../BaseConfig/GetSetBaseConfig.js"></script>
     <script>
         var ParamName = "";
         $(function () {
             $('#areascontent').height($(window).height() - 8);
             InitData();
        });

        function InitData() {
            ParamName = request('ParamName');
            ParamDsca = request('ParamDsca');
            $("#ParamName").text(ParamName);
            $("#ParamDsca").text(decodeURI(decodeURI(ParamDsca)));
        }

        function AcceptClick(grid) {
            $.ajax({
                url: "GetSetMfg.ashx",
                data: {
                    "Action": "MFG_PLC_TRIG_MT",
                    "ParamName": ParamName,
                    "ParamValue": "TRUE",
                    "ProcessCode": ""
                },
                async: true,
                type: "post",
                datatype: "json",
                success: function (data) {
                    Loading(false);
                    data = JSON.parse(data);
                    if (data.result == "success") {
                        window.parent.$('#gridTable').trigger("reloadGrid");
                        dialogMsg("手动物料拉动成功", 1);
                        dialogClose();
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
                    Loading(true, "正在手动物料拉动.");
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
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body1" class="body">
    <!--主体-->
    <div id="areascontent" style="margin:10px 5px 5px 5px; margin-bottom: 0px; overflow: auto;">
        <div class="gridPanel">
            拉动点: <span id="ParamName"></span>
        </div>
        <div class="gridPanel"> 
            拉动点描述: <span id="ParamDsca"></span>
        </div>
    </div>

    <style>
        *{
            font-size:15px; 
         }

        @media screen and (max-width: 1400px) { 
           .formTitle {
               font-size:15px;
               width:200px;
           } 
           #form1{
               margin:0px 0px 0px 5px;
           }
       } 
       @media screen and (min-width: 1400px) { 
          .formTitle {
              font-size:30px;
              width:300px;
          } 
           #form1{
               margin: 0px 0px 0px 5px;
           }
       } 
     </style>
    
</body>
</html>
