<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquTotalReport.aspx.cs" Inherits="LiNuoMes.Report.EquTotalReport" %>

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
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
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

    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
    <script>
        $(function () {
            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height());
            //$('#gridTable').setGridWidth(($('.gridPanel').width()));
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height());
                }, 200);
            });
            GetGrid();
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                datatype: "local",
                height: $('#areascontent').height() * 0.7,
                colModel: [
                  {
                      label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 300, align: 'left', sortable: false
                  },
                  { label: '一级保养次数', name: 'FirstLevelCount', index: 'FirstLevelCount', width: 100, align: 'left', sortable: false },
                  {
                      label: '二级保养次数', name: 'SecondLevelCount', index: 'SecondLevelCount', width: 100, align: 'left', sortable: false
                  }
                ],
                viewrecords: true,
                rowNum: "10000",
                rownumbers: true,
                rownumWidth: 100,
                shrinkToFit: false,
                autowidth: true,
                gridview: true,
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                },
                gridComplete: function () {
                    $("#" + this.id).setSelection(selectedRowIndex, false);

                }
            });

            $gridTable.jqGrid('setLabel', 'rn', '序号', {
                'text-align': 'center'
            });

            //查询事件
            $("#btn_Search").click(function () {
                var currentdate = $("#currentdate").val();
                var endDate = $("#endDate").val();

                $gridTable.jqGrid('setGridParam', {
                    datatype: "json",
                    postData: {
                        Action: "GetEquTotalReport",
                        currentdate: currentdate,
                        endDate: endDate
                    }, page: 1
                }).trigger('reloadGrid');
            });
        }

    </script>

    <div id="areascontent" style="margin:0px 10px 0px 10px; margin-bottom: 0px; overflow: auto;">
    <div class="rows" style="margin-top:0.5%; overflow: hidden; ">
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
            <table class="form" id="ruleinfo" style="margin-top:10px;">
               <tr>
                   <th class="formTitle" >查询日期：</th>
                   <td class="formValue" colspan="2" >
                       <input id="currentdate"  type="text" onfocus="WdatePicker({ maxDate: '#F{$dp.$D(\'endDate\')}', dateFmt: 'yyyy-MM-dd' })"  class="Wdate" readonly /><span id="tag">至</span>
                       <input id="endDate"  type="text"   onfocus="WdatePicker({ minDate: '#F{$dp.$D(\'currentdate\')}', dateFmt: 'yyyy-MM-dd' })"    class="Wdate" readonly /> 
                   </td>
                   <td class="formValue">                                     
                       <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>  
                   </td>
                <tr> 
            </table>
           
     </div>
     </div>
     <div class="rows" style="margin-top:0.5%; overflow: hidden; ">
         
          <div class="gridPanel">
               <table id="gridTable"></table>
          </div>
     </div>
     </div>
   <style>
    .form .formTitle {
        width:100px;
        font-size:9pt;
    }
    .timeselect{
        width:200px;
        height:30px;
    }
    </style>
</body>
</html>

