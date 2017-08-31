<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerConfig.aspx.cs" Inherits="LiNuoMes.BaseConfig.CustomerConfig" %>

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
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    
    <script>
        $(function () {
            $('#areascontent').css("margin-right", "0px");
            $('#areascontent').height(400);
            InitPage();
        });

        //加载表格
        function InitPage() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "../BaseConfig/GetSetBaseConfig.ashx",
                postData: { Action: "MES_CUSTOMER_LIST" },
                datatype: "json",
                height: $('#areascontent').height() - 150,
                width:  $('#areascontent').width() - 20,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                    id: "ID"              //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                },
                colModel: [
                    { label: '序号', name: 'CustomerID', index: 'CustomerID', width: 50, align: 'center', sortable: false },
                    { label: '客户名称', name: 'CustomerName', index: 'CustomerName', width: 120, align: 'center', sortable: false },
                    { label: '客户Logo文件', name: 'CustomerLogo', index: 'CustomerLogo', width: 220, align: 'center', sortable: false },
                    {
                        label: '操 作', width: 110, align: 'center', sortable: false,
                    formatter: function (cellvalue, options, rowObject) {
                            return '<button onclick=\"showdlg(\'EDIT\',  \'' + rowObject.CustomerID + '\')\" class=\"btn btn-success\" style=\"cursor:pointer;margin-left:5px;padding:.2em .6em .3em;font-size:14px;"><i class="fa fa-edit"></i>修改</button>';
                        }
                    },
                ],
                shrinkToFit: true,
                autowidth: true,
                scrollrows: true,
                gridview: true,
         //       viewsortcols:[false, false, false],
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                },
                gridComplete: function () {
                    $("#" + this.id).setSelection(selectedRowIndex, false);
                }
            });
        }

        //新建
        function btn_Add(event) {
            var isSuccess = 0;
            showdlg('ADD', 0);
            if (isSuccess == 0) {
                $("#gridTable").trigger("reloadGrid");
            }
        }

        function AcceptClick(func) {
            func();
            dialogClose();
            return;

        }


        //编辑信息
        function showdlg(OPtype, CustId) {
            if (CustId == undefined) {
                CustId = $("#gridTable").getRowData(selectedRowIndex)["ID"];
            }

            if (OPtype == undefined) {
                OPtype = "CHECK";
            }

            else if (OPtype == "EDIT") {
                sTitle = "修改客户信息";
            }
            else if (OPtype == "ADD") {
                sTitle = "新增客户信息";
            }

            dialogOpen({
                id: "FormCustomerDetail",
                title: sTitle,
                url: "../BaseConfig/CustomerDetailEdit.aspx?OPtype=" + OPtype + "&CustId=" + CustId,
                width: "580px",
                height: "200px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }
   </script>
</head>
<body >
    <div id="areascontent" style="margin:1px; overflow: auto;">
         <div class="rows" style="margin-top:1px; margin-bottom: 1px; margin-right:10px;">
            <div class="panel panel-default">
                <div class="panel-body" style="text-align:right">
                    <a id="btn_Add" class="btn btn-primary" onclick="btn_Add(event)" style="cursor:pointer;margin-left:5px;padding:.2em .6em .3em;font-size:14px;"> <i class="fa fa-plus"></i>&nbsp;新建</a>
                </div>
            </div>
         </div>

         <div class="rows" style="margin-top:1px; overflow: visible; ">
              <div class="gridPanel">
                   <table id="gridTable"></table>
                   <div id="gridPager"></div>
              </div>
         </div>
    </div>
    
</body>
</html>
