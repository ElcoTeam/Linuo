<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserInfo.aspx.cs" Inherits="LiNuoMes.UserManage.UserInfo" %>

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
            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height()-106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height()-106);
                }, 200);
            });
            GetGrid();
            CreateSelect();
            
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
           
            $gridTable.jqGrid({
                url: "hs/GetUserInfo.ashx",
                datatype: "json",
                height: $('#areascontent').height() - 250,
                //styleUI: 'Bootstrap',
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    {
                        label: '登录账号', name: 'UserID', index: 'UserID', width: 200, align: 'left', sortable: false
                    },
                    { label: '员工姓名', name: 'UserName', index: 'UserName', width: 300, align: 'left', sortable: false },
                    {
                        label: '角色名称', name: 'RoleName', index: 'RoleName', width: 400, align: 'left', sortable: false
                    },
                    {
                        label: '操作', width: 100, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '<span onclick=\"btn_search(\'' + rowObject[0]+ '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>' + '<span onclick=\"btn_edit(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:20px;\"><i class="fa fa-edit"></i>编辑</span>' + '<span onclick=\"btn_delete(\'' + rowObject[0] + '\')\" class=\"label label-danger\" style=\"cursor: pointer;margin-left:20px;\"><i class="fa fa-trash-o"></i>删除</span>';
                        }
                    },
                ],
                viewrecords: true,
                //altRows: true,
                rowNum: 30,
                rownumWidth: 100,
                rowList: [30, 50, 100],
                pager: "#gridPager",
                sortname: 'ID',
                rownumbers: true,
                shrinkToFit: false,
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

            $gridTable.jqGrid('setLabel', 'rn', '序号', {
                'text-align': 'center'
            });
            //查询事件
            $("#btn_Search").click(function () {
                var userno = $("#userno").val();
                var username = $("#username").val();
                var rolename = $("#rolename").val();
                $gridTable.jqGrid('setGridParam', {
                    postData: { Userno: userno, Username: username, Rolename: rolename }, page: 1
                }).trigger('reloadGrid');
            });
            //查询回车
            $('#rolename').bind('keypress', function (event) {
                if (event.keyCode == "13") {
                    $('#btn_Search').trigger("click");
                }
            });
        }

        //构造select
        function CreateSelect() {
            $("#rolename").empty();
            var optionstring = "";
            //var optionstring1 = "";
            $.ajax({
                url: "UserInfo.aspx/GetUserRole",    //后台webservice里的方法名称  
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;//和for循环一样 i做计数
                    for (i in data1) {
                        optionstring += "<option value=\"" + data1[i].RoleID + "\" >" + data1[i].RoleName.trim() + "</option>";
                    }
                    $("#rolename").html("<option value=''>请选择...</option> " + optionstring);
                    //$("#roleselect").html("<option value=''>请选择...</option> " + optionstring);
                },
                error: function (msg) {
                    alert("数据访问异常");
                }
            });
           
        }

        //新建人员
        function btn_Add(event) {
           
            dialogOpen({
                id: "Form",
                title: '新增人员信息',
                url: '../UserManage/UserDetailInfo.aspx',
                width: "600px",
                height: "400px",
                async:false,
                callBack: function (iframeId) {                 
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                   
                }
            });
        }

        //查看人员信息
        function btn_search(uesrid) {
            
            if (userid == undefined) {
                uesrid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '查看人员信息',
                url: '../UserManage/UserDetailSearch.aspx?userid=' + uesrid + '',
                width: "600px",
                height: "400px",
                btn: null
                //btn: ['确认'],
            });
        }

        //编辑人员信息
        function btn_edit(userid) {
            if (userid == undefined) {
                userid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '编辑人员信息',
                url: '../UserManage/UserDetailEdit.aspx?userid=' + userid + '',
                width: "600px",
                height: "400px",
                callBack: function (iframeId) {
                    console.log(top.frames[iframeId]);
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        //删除人员信息
        function btn_delete(userid) {
            if (userid == undefined) {
                userid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                if (r) {
                    Loading(true, "正在删除数据...");
                    window.setTimeout(function () {
                        $.ajax({
                            url: "UserInfo.aspx/DeleteUserInfo",
                            data: "{UserID:'" + userid + "'}",
                            type: "post",
                            dataType: "json",
                            contentType: "application/json;charset=utf-8",
                            success: function (data) {
                                if (data.d == "success") {
                                    Loading(false);
                                    dialogMsg("删除成功", 1);
                                    $("#gridTable").trigger("reloadGrid");
                                }
                                else if (data.d == "falut") {
                                    dialogMsg("删除失败", -1);
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
<body data-spy="scroll" data-target=".navbar-example" id="body1" class="body" >

    <!--nav-->
    <div class="navbar navbar-inverse navbar-fixed-top" id="nav">
        
    </div>
    <!--end nav-->
   
    <!--导航栏-->
    <div class="yn jz container-fluid nav-bgn m0" id="menu_wrap">
        
    </div>

    <!--主体-->
   
        <div id="areascontent" style="margin:50px 10px 0px 10px; margin-bottom: 0px; overflow: auto;">
             <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">人员信息管理</strong></div>
                           <div class="panel-body">
                            <table id="form1" class="form">
                                <tr>
                                    <th class="formTitle">登录账号：</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="userno" placeholder="请输入登录账号">
                                    </td>
                                    <th class="formTitle">员工姓名：</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="username" placeholder="请输入员工姓名">
                                    </td>
                                    <td class="formValue">
                                          <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a> 
                                          <a id="btn_Add" class="btn btn-primary" onclick="btn_Add(event)"><i class="fa fa-plus"></i>&nbsp;新建</a>                          
                                     </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">角色名称：</th>
                                    <td class="formValue">
                                         <select class="form-control" id="rolename">
                                         </select>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
       
             <div class="rows" style="margin-top:0.5%; overflow: hidden; ">
                  <div class="gridPanel">
                       <table id="gridTable"></table>
                       <div id="gridPager"></div>
                  </div>
             </div>
        </div>
</body>
</html>
