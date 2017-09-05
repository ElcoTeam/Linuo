<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialBkfConfig.aspx.cs" Inherits="LiNuoMes.Mfg.MaterialBkfConfig" %>

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
    <script src="../My97DatePicker/WdatePicker.js"></script>
    
    <script>
        var selectedRowIndex = 0;
        $(function () {

            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height() - 106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#areascontent').height($(window).height() - 106);
                //    $('#areascontent').width($(window).width() - 20);  //此处隐藏的两项不要加入,如果加入会引起死机:原因:貌似引起了递归调用.
                    $('#gridTable').setGridWidth(($('#areascontent').width()) - 10);
                //    $('#gridTable').setGridHeight($('#areascontent').height() - 200);
                }, 200);
            });

            InitPage();

            $("#btn_Create").click(function () {
                showdlg("ADD","0");
            });

            $("#btn_Reload").click(function () {
                $('#gridTable').trigger("reloadGrid");
            });

        });

        function InitPage() {
            var panelwidth = $('#areascontent').width();
            var strBtnStyle = "cursor:pointer;margin-left:5px;font-weight:700;padding:.2em .6em .3em;font-size:14px;";
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "./GetSetMfg.ashx",
                postData: {
                    "Action": "MFG_WIP_BKF_ITEM_LIST"
                },
                datatype: "json",
                height: $('#areascontent').height() - 170,
                width: $('#areascontent').width,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                    id: "ID"              //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                },
                colModel: [
                    { label: 'ID', name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber',  index: 'InturnNumber', width: panelwidth * 0.03, align: 'center', sortable: false },
                    { label: '物料编码', name: 'ItemNumber', index: 'ItemNumber',   width: panelwidth * 0.11, align: 'center', sortable: false },
                    { label: '物料描述', name: 'ItemDsca',   index: 'ItemDsca',     width: panelwidth * 0.25, align: 'left',   sortable: false },
                    { label: '单位',    name: 'UOM',        index: 'UOM',          width: panelwidth * 0.03, align: 'center', sortable: false },
                    { label: '创建人员', name: 'CreateUser', index: 'CreateUser',   width: panelwidth * 0.08, align: 'center', sortable: false },
                    { label: '创建时间', name: 'CreateTime', index: 'CreateTime',   width: panelwidth * 0.14, align: 'center', sortable: false },
                    { label: '更新人员', name: 'ModifyUser', index: 'ModifyUser',   width: panelwidth * 0.08, align: 'center', sortable: false },
                    { label: '更新时间', name: 'ModifyTime', index: 'ModifyTime',   width: panelwidth * 0.14, align: 'center', sortable: false },
                    { label: '操 作',   name: 'OperateCol',                        width: panelwidth * 0.14, align: 'center', sortable: false },

                ],
                shrinkToFit: true,
                autowidth: true,
                scroll: true,
                multiselect: false,
                gridview: true,
                onSelectRow: function (rowid) {
                    selectedRowIndex = $("#gridTable").jqGrid("getGridParam", "selrow");
                },
                gridComplete: function () {
                    $("#gridTable").setSelection(selectedRowIndex, true);
                    var ids = $gridTable.jqGrid('getDataIDs'); //获取表格的所有列
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        var strOperate   = '<button onclick=\"showdlg( \'EDIT\',\'' + id + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-edit"></i>修改</span>';
                            strOperate  += '<button onclick=\"btnDelete(        \'' + id + '\')\" class=\"btn btn-danger\"  style=\"' + strBtnStyle + '\"><i class="fa fa-edit"></i>删除</span>';
                        $gridTable.jqGrid('setRowData', ids[i], { OperateCol: strOperate });
                    }
                }
            });

        }

        //编辑信息
        function showdlg(OPtype, ItemId) {
            if (ItemId == undefined) {
                ItemId = $("#gridTable").jqGridRowValue("ID");
            }

            if (OPtype == undefined) {
                OPtype = "ADD";
            }

            var sTitle = "";
            var sUrl = "";
            var sWidth = "400px";
            var sHeight = "200px"
            sUrl = "MaterialBkfItemEdit.aspx";

            if (OPtype == "EDIT") {
                sTitle = "修改反冲物料";
            }
            else if (OPtype == "ADD") {
                sTitle = "新增反冲物料";
            }             

            dialogOpen({
                id: "Form",
                title: sTitle,
                url: sUrl + "?OPtype=" + OPtype + "&ItemId=" + ItemId,
                width: sWidth,
                height: sHeight,
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        //删除信息
        function btnDelete(ItemId) {
            if (ItemId == undefined) {
                ItemId = $("#gridTable").jqGridRowValue("ID");
            }
            dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                if (r) {
                    Loading(true, "正在删除数据...");
                    window.setTimeout(function () {
                        $.ajax({
                            url: "GetSetMfg.ashx",
                            data: {
                                "Action": "MFG_WIP_BKF_ITEM_LIST_DELETE",
                                "ItemId":ItemId
                            },
                            type: "post",
                            datatype: "json",
                            success: function (data) {
                                data = JSON.parse(data);
                                if (data.result == "success") {
                                    Loading(false);
                                    dialogMsg("删除成功", 1);
                                    $('#gridTable').trigger("reloadGrid");
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
                                Loading(true, "正在删除数据");
                            },
                            complete: function () {
                                Loading(false);
                            }
                        });
                    }, 500);
                }
            });
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
    <div id="areascontent" style="margin:50px 10px 0px 10px; margin-bottom: 0px; overflow: auto;">
         <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading" >
                            <table id="panelheading" border="0" style="width:100%">
                                <tr>
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px">反冲物料料号管理</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table class="form" style="width:100%">
                                <tr>                                  
                                    <td class="formValue" style="text-align:right;" colspan="1">                                           
                                        <a id="btn_Reload" class="btn btn-primary"><i class="fa fa-refresh"></i>刷新</a>
                                        <a id="btn_Create" class="btn btn-primary"><i class="fa fa-plus"></i>新建</a>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="rows" style="margin-top:0.5%; width:100%; overflow: hidden; ">
                              <div class="gridPanel">
                                   <table id="gridTable"></table>
                              </div>
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
               width:60px;
           } 

           .formValue {
               font-size:15px;
               width:260px;
               height:30px;
               margin-left:5px;
               margin-right:5px;
           }

           #form1{
               margin:0px 0px 0px 5px;
           }
       } 
       @media screen and (min-width: 1400px) { 
          .formTitle {
              font-size:20px;
              width:60px;
          } 
          .formValue {
               font-size:20px;
               width:280px;
               height:40px;
               margin-left:5px;
               margin-right:5px;
           }
           #form1{
               margin: 0px 0px 0px 5px;
           }
       } 
     </style>
    
</body>
</html>
