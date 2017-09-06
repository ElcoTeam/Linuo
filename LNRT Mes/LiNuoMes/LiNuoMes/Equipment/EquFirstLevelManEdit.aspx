<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquFirstLevelManEdit.aspx.cs" Inherits="LiNuoMes.Equipment.EquFirstLevelManEdit" %>
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
             if (equid == undefined) {
                 equid = 0;
             }
         
             $.ajax({
                 url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                 data: {
                     "Action": "EquFirstLevelMaintenceMan_Detail",
                     "EquID": equid
                 },
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     $("#ProcessName").val( data.ProcessCode );
                     $("#DeviceName").val(data.DeviceName);
                     $("#PmOper").val(data.PmOper);
                     $("#PmComment").val(data.PmComment);
                     $("#FindProblem").html(data.FindProblem);
                     $("#RepairProblem").html(data.RepairProblem);
                     $("#ReaminProblem").html(data.ReaminProblem);
                     Loading(false);
                 }, beforeSend: function () {
                     Loading(true);
                 }
             });
         });

         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }

    </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
            <table class="form" id="ruleinfo" style="margin-top:10px;">
                <tr>
                    <th class="formTitle">工序名称</th>
                    <td class="formValue">
                         <input id="ProcessName" type="text" class="form-control" readonly/>
                    </td>
                     <th class="formTitle">设备名称</th>
                    <td class="formValue">
                        <input id="DeviceName" type="text"  class="form-control" readonly/>
                    </td>
                </tr>
               
                <tr >
                    <th class="formTitle">保养人</th>
                    <td class="formValue">
                        <input id="PmOper" type="text" class="form-control"  readonly/>        
                    </td>
                </tr>
                <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        问题记录
                    </th>
                    <td class="formValue" colspan="3">
                        <textarea id="PmComment"  class="form-control" style="height: 150px;" ></textarea>
                    </td>
                </tr> 
                 <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        
                    <td colspan="3" >
                        <ul>
                            <li style="padding-top:10px;">设备进行点检发现问题共<label id="FindProblem" class="problemcount"></label>次</li>
                            <li style="padding-top:10px;">维修解决问题共<label id="RepairProblem"   class="problemcount"></label>次</li>
                            <li style="padding-top:10px;">遗留问题存在<label id="ReaminProblem"  class="problemcount" ></label>次</li>
                        </ul>
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

