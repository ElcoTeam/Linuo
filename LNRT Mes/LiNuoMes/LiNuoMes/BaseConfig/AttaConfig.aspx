<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AttaConfig.aspx.cs" Inherits="LiNuoMes.BaseConfig.AttaConfig" %>

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
        var GoodsCode;
        var MainItem;

        $(function () {
            GoodsCode = request('GoodsCode');
            MainItem  = request('MainItem');
            $('#areascontent').css("margin-right", "0px");
            $('#areascontent').height(470);
            InitPage();
        });

        //加载表格
        function InitPage() {
            var selectedRowIndex = 0;
            $('#gridTable').jqGrid({
                url: "../BaseConfig/GetSetBaseConfig.ashx",
                postData: {
                    "Action": "MES_MTL_PULL_ITEM_ATTACHED",
                    "GoodsCode": GoodsCode,
                    "MainItem": MainItem
                },
                datatype: "json",
                height: $('#areascontent').height() - 150,
                width:  $('#areascontent').width()  - 20,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                    id: "ID"              //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                },
                colModel: [
                    { label: 'ID', name: 'ID', index: 'ID', hidden:true },
                    { label: '序号', name: 'InturnNumber',  index: 'InturnNumber', width: 50,  align: 'center', sortable: false },
                    { label: '物料料号', name: 'ItemNumber', index: 'ItemNumber',   width: 130, align: 'center', sortable: false },
                    { label: '物料描述', name: 'ItemDsca',   index: 'ItemDsca',     width: 340, align: 'center', sortable: false },
                    { label: '用料比例', name: 'RatioQty',   index: 'RatioQty',     width: 80,  align: 'center', sortable: false },
                    {
                        label: '操 作', width: 90, align: 'center', sortable: false,
                    formatter: function (cellvalue, options, rowObject) {
                        return '<button onclick=\"btn_Delete(\'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"cursor:pointer;margin-left:5px;padding:.2em .6em .3em;font-size:14px;"><i class="fa fa-times"></i>删除</button>';
                        }
                    },
                ],
                shrinkToFit: true,
                autowidth: true,
                scrollrows: true,
                gridview: true,
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
            showdlg();
            if (isSuccess == 0) {
                $("#gridTable").trigger("reloadGrid");
            }
        }

        function btn_Delete(AttaID) {
            if (confirm("请您确认您确实要删除此条记录吗?")) {
                $.ajax({
                    url: "../BaseConfig/GetSetBaseConfig.ashx",
                    data: {
                        "Action": "MES_MTL_PULL_ITEM_ATTACHED_DELETE",
                        "AttaID": AttaID
                    },
                    type: "post",
                    datatype: "json",
                    success: function (data) {
                        $("#gridTable").trigger("reloadGrid");
                    },
                    error: function (msg) {
                        alert(msg.responseText);
                    }
                });
            }
        }

        function AcceptClick(iframeId) {
            dialogClose();
            return;
        }

        //编辑信息
        function showdlg() {
            sTitle = "新增物料信息";
            dialogOpen({
                id: "FormCustomerDetail",
                title: sTitle,
                url: "../BaseConfig/AttaDetailEdit.aspx?GoodsCode=" + GoodsCode + "&MainItem=" + MainItem,
                width: "400px",
                height: "220px",
               // btn:['确认','关闭'],
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
                    <a id="btn_Add" class="btn btn-primary" onclick="btn_Add(event)" style="cursor:pointer;margin-left:5px;padding:.2em .6em .3em;font-size:14px;"> <i class="fa fa-plus"></i>&nbsp;新增</a>
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
