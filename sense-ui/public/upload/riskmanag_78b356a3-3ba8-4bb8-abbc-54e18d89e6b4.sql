/*
 Navicat Premium Data Transfer

 Source Server         : 阿里云
 Source Server Type    : MySQL
 Source Server Version : 50568
 Source Host           : 123.57.17.156:3306
 Source Schema         : riskmanage

 Target Server Type    : MySQL
 Target Server Version : 50568
 File Encoding         : 65001

 Date: 15/06/2022 10:06:35
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for rmc_analysis_policy
-- ----------------------------
DROP TABLE IF EXISTS `rmc_analysis_policy`;
CREATE TABLE `rmc_analysis_policy`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID，唯标识',
  `analysis_policy_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '风险分析策略名称',
  `analysis_policy_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '风险分析策略编号',
  `analysis_policy_param` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '风险分析sql',
  `analysis_policy_desc` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '风险分析策略描述',
  `analysis_policy_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '风险分析策略类型 0:sql类型 1:固定字段',
  `analysis_policy_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态0无效 1有效',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '风险分析策略表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_analysis_policy
-- ----------------------------
INSERT INTO `rmc_analysis_policy` VALUES ('954800870903611392', '常用浏览器分析策略', 'analysis001', 'select count from rmc_user_browser where user_sn=#userSn# and browser=#browser#', '常用浏览器分析策略', '0', '1');
INSERT INTO `rmc_analysis_policy` VALUES ('954801119905910784', '常用IP分析策略', 'analysis002', 'select count from rmc_user_ip where user_sn=#userSn# and ip=#ip#', '常用IP分析策略', '0', '1');

-- ----------------------------
-- Table structure for rmc_analysis_score_policy
-- ----------------------------
DROP TABLE IF EXISTS `rmc_analysis_score_policy`;
CREATE TABLE `rmc_analysis_score_policy`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID，唯标识',
  `analysis_policy_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '风险分析策略编码',
  `conditional_expression` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '条件表达式',
  `analysis_score` int(11) NOT NULL COMMENT '风险分数',
  `analysis_score_policy_desc` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '风险分析分值计算策略描述',
  `analysis_score_policy_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '状态0无效 1有效',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '风险分析分值计算策略表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_analysis_score_policy
-- ----------------------------
INSERT INTO `rmc_analysis_score_policy` VALUES ('954809117119995904', 'analysis001', 'staCount>0 && staCount<=10', 50, NULL, '1');
INSERT INTO `rmc_analysis_score_policy` VALUES ('954809254561927168', 'analysis001', 'staCount>10', 100, NULL, '1');
INSERT INTO `rmc_analysis_score_policy` VALUES ('954809422094471168', 'analysis001', 'staCount==0', 0, NULL, '1');
INSERT INTO `rmc_analysis_score_policy` VALUES ('954809475519217664', 'analysis002', 'staCount==0', 0, NULL, '1');
INSERT INTO `rmc_analysis_score_policy` VALUES ('954809549421363200', 'analysis002', 'staCount>0 && staCount<=10', 50, NULL, '1');
INSERT INTO `rmc_analysis_score_policy` VALUES ('954809622830612480', 'analysis002', 'staCount>10', 100, NULL, '1');

-- ----------------------------
-- Table structure for rmc_auth_log
-- ----------------------------
DROP TABLE IF EXISTS `rmc_auth_log`;
CREATE TABLE `rmc_auth_log`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户账号',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名称',
  `login_status` tinyint(1) NULL DEFAULT NULL COMMENT '登录状态 0：失败 1：成功',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '认证日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_auth_log
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_blackwhite
-- ----------------------------
DROP TABLE IF EXISTS `rmc_blackwhite`;
CREATE TABLE `rmc_blackwhite`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID，唯标识',
  `blackwhite_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '黑白名单名称',
  `blackwhite_param` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '黑白名单字段',
  `blackwhite_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '黑白名单值',
  `blackwhite_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '黑白名单类型BLACK 黑名单  WHITE白名单',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '黑白名单列表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_blackwhite
-- ----------------------------
INSERT INTO `rmc_blackwhite` VALUES ('955070902991515648', '黑名单', 'userSn', 'SN20*', 'BLACK');
INSERT INTO `rmc_blackwhite` VALUES ('955072077787111424', '白名单', 'userSn', 'SN00*', 'WHITE');

-- ----------------------------
-- Table structure for rmc_blackwhite_param
-- ----------------------------
DROP TABLE IF EXISTS `rmc_blackwhite_param`;
CREATE TABLE `rmc_blackwhite_param`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID，唯标识',
  `blackwhite_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '黑白名单编码',
  `blackwhite_param` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '黑白名单对应字段',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '黑白名单对应字段表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_blackwhite_param
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_blackwhite_value
-- ----------------------------
DROP TABLE IF EXISTS `rmc_blackwhite_value`;
CREATE TABLE `rmc_blackwhite_value`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID，唯标识',
  `blackwhite_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '黑白名单编码',
  `blackwhite_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '黑白名单值',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '黑白名单值表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_blackwhite_value
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_field
-- ----------------------------
DROP TABLE IF EXISTS `rmc_field`;
CREATE TABLE `rmc_field`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID，唯标识',
  `field_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '字段名',
  `field_dispaly_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '字段显示名称',
  `field_data_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '字段数据类型',
  `log_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '对应日志编号',
  `log_table` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '表名',
  `log_table_colum_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '列名',
  `field_create_mode` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '创建方式自动0,逻辑处理1',
  `field_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态0无效1有效',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '风控字段表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_field
-- ----------------------------
INSERT INTO `rmc_field` VALUES ('951816347874877440', 'browser', '浏览器', 'String', 'loginLog', 'rmc_login_log', 'browser', '0', '1');
INSERT INTO `rmc_field` VALUES ('951835920010268672', 'ip', '登录IP', 'String', 'loginLog', 'rmc_login_log', 'ip', '0', '1');
INSERT INTO `rmc_field` VALUES ('951843169692766208', 'userSn', '用户账号', 'String', 'loginLog', 'rmc_login_log', 'user_sn', '0', '1');
INSERT INTO `rmc_field` VALUES ('951843516356726784', 'userName', '用户姓名', 'String', 'loginLog', 'rmc_login_log', 'user_name', '0', '1');
INSERT INTO `rmc_field` VALUES ('951915979542978560', 'system', '操作系统', 'String', 'loginLog', 'rmc_login_log', 'system', '0', '1');
INSERT INTO `rmc_field` VALUES ('954426925649981440', 'city', '城市', 'String', 'loginLog', 'rmc_user_city', 'city', '0', '1');
INSERT INTO `rmc_field` VALUES ('954735973393715200', 'phoneType', '手机系统', 'String', 'loginLog', 'rmc_login_log', 'type', '0', '1');
INSERT INTO `rmc_field` VALUES ('954736579731501056', 'phoneIdentifier', '手机唯一标识', 'String', 'loginLog', 'rmc_login_log', 'identifier', '0', '1');

-- ----------------------------
-- Table structure for rmc_login_log
-- ----------------------------
DROP TABLE IF EXISTS `rmc_login_log`;
CREATE TABLE `rmc_login_log`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名称',
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户账号',
  `browser` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '浏览器',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '登录IP',
  `system` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作系统',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '城市 ',
  `type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机系统',
  `identifier` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机唯一标识 ',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '登录日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_login_log
-- ----------------------------
INSERT INTO `rmc_login_log` VALUES ('954804527621505024', NULL, 'zahngmazi', 'IE13', '198.198.198.12', 'Windows10', 'ShangHai', NULL, 'asdasdasdadasdasdasd', NULL);
INSERT INTO `rmc_login_log` VALUES ('954805440148217856', NULL, 'zahngmazi', 'IE13', '198.198.198.12', 'Windows10', 'ShangHai', NULL, 'asdasdasdadasdasdasd', NULL);
INSERT INTO `rmc_login_log` VALUES ('954805784138514432', NULL, 'zahngmazi', 'IE13', '198.198.198.12', 'Windows10', 'ShangHai', NULL, 'asdasdasdadasdasdasd', '2021-09-23 16:16:04');
INSERT INTO `rmc_login_log` VALUES ('954815867662053376', NULL, 'zahngmazi', 'IE13', '198.198.198.12', 'Windows10', 'ShangHai', 'HUAWEIc8815', 'HUAWEIadsfasdfasdfads123', '2021-09-23 16:56:08');
INSERT INTO `rmc_login_log` VALUES ('954816322102308864', NULL, 'zahngmazi', 'IE13', '198.198.198.12', 'Windows10', 'ShangHai', 'HUAWEIc8815', 'HUAWEIadsfasdfasdfads123', '2021-09-23 16:57:57');
INSERT INTO `rmc_login_log` VALUES ('954816454966902784', NULL, 'zahngmazi', 'IE13', '198.198.198.12', 'Windows10', 'ShangHai', 'HUAWEIc8815', 'HUAWEIadsfasdfasdfads123', '2021-09-23 16:58:28');
INSERT INTO `rmc_login_log` VALUES ('954816563480309760', NULL, 'zahngmazi', 'IE13', '198.198.198.12', 'Windows10', 'ShangHai', 'HUAWEIc8815', 'HUAWEIadsfasdfasdfads123', '2021-09-23 16:58:54');
INSERT INTO `rmc_login_log` VALUES ('954816682487058432', NULL, 'zahngmazi', 'IE13', '198.198.198.12', 'Windows10', 'ShangHai', 'HUAWEIc8815', 'HUAWEIadsfasdfasdfads123', '2021-09-23 16:59:23');
INSERT INTO `rmc_login_log` VALUES ('954818551229300736', NULL, 'zahngmazi', 'IE13', '198.198.198.12', 'Windows10', 'ShangHai', 'HUAWEIc8815', 'HUAWEIadsfasdfasdfads123', '2021-09-23 17:06:48');
INSERT INTO `rmc_login_log` VALUES ('954818788719181824', NULL, 'zahngmazi', 'IE13', '198.198.198.12', 'Windows10', 'ShangHai', 'HUAWEIc8815', 'HUAWEIadsfasdfasdfads123', '2021-09-23 17:07:45');

-- ----------------------------
-- Table structure for rmc_resource
-- ----------------------------
DROP TABLE IF EXISTS `rmc_resource`;
CREATE TABLE `rmc_resource`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID，唯标识',
  `resource_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '资源名称',
  `resource_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '资源编码',
  `resource_desc` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '资源描述',
  `resource_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态0无效 1有效',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '受保护资源表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_resource
-- ----------------------------
INSERT INTO `rmc_resource` VALUES ('954800534361047040', '金科门户资源', 'resoucs001', NULL, '1');
INSERT INTO `rmc_resource` VALUES ('955164435838255104', '01', '11', '11', '1');

-- ----------------------------
-- Table structure for rmc_resource_analysis_policygroup
-- ----------------------------
DROP TABLE IF EXISTS `rmc_resource_analysis_policygroup`;
CREATE TABLE `rmc_resource_analysis_policygroup`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID，唯标识',
  `resource_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '受保护资源编码',
  `risk_analysis_policy_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '风险分析策略编码',
  `analysis_policy_weight` int(11) NOT NULL COMMENT '权重',
  `analysis_policy_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态0无效 1有效',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '资源风险分析策略组表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_resource_analysis_policygroup
-- ----------------------------
INSERT INTO `rmc_resource_analysis_policygroup` VALUES ('954806533796614144', 'resoucs001', 'analysis001', 15, '1');
INSERT INTO `rmc_resource_analysis_policygroup` VALUES ('954806565636386816', 'resoucs001', 'analysis002', 15, '1');

-- ----------------------------
-- Table structure for rmc_resource_protected_policy
-- ----------------------------
DROP TABLE IF EXISTS `rmc_resource_protected_policy`;
CREATE TABLE `rmc_resource_protected_policy`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID，唯标识',
  `resource_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '受保护资源编码',
  `protected_policy_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '资源管控策略名称',
  `protected_policy_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '资源管控策略编码',
  `score_expression` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分值范围表达式',
  `access_policy` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '认证策略',
  `protected_policy_desc` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '资源管控策略描述',
  `protected_policy_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态0无效 1有效',
  `protected_policy_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '资源管控类型 ANALYSIS:分析策略 BLACK:黑名单策略 WHITE:白名单策略',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '资源管控策略表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_resource_protected_policy
-- ----------------------------
INSERT INTO `rmc_resource_protected_policy` VALUES ('954807116587982848', 'resoucs001', '门户资源分值认证', 'GK001', 'scope>0 && scope<10', '[1]', NULL, '1', 'ANALYSIS');
INSERT INTO `rmc_resource_protected_policy` VALUES ('954807268756520960', 'resoucs001', '门户资源分值认证', 'GK002', 'scope>=50 && scope<=100', '[2]', NULL, '1', 'ANALYSIS');
INSERT INTO `rmc_resource_protected_policy` VALUES ('954807403368919040', 'resoucs001', '	 门户资源分值认证', 'GK003', 'scope>100', '[9]', NULL, '1', 'ANALYSIS');
INSERT INTO `rmc_resource_protected_policy` VALUES ('954811142276091904', 'resoucs001', '门户资源分值认证', 'GK004', 'scope>=10 && scope<50', '[3]', NULL, '1', 'ANALYSIS');
INSERT INTO `rmc_resource_protected_policy` VALUES ('955063941018652672', 'resoucs001', '节假日登录问题', 'gk006', 'scope>=0 && scope<=100', '[6]', NULL, '1', 'ANALYSIS');
INSERT INTO `rmc_resource_protected_policy` VALUES ('955071234140340224', 'resoucs001', '登录人黑名单', 'BLACK001', NULL, '[6]', NULL, '1', 'BLACK');
INSERT INTO `rmc_resource_protected_policy` VALUES ('955072414543585280', 'resoucs001', '白名单 ', 'WHITE001', NULL, '[7]', NULL, '1', 'WHITE');

-- ----------------------------
-- Table structure for rmc_resource_switch
-- ----------------------------
DROP TABLE IF EXISTS `rmc_resource_switch`;
CREATE TABLE `rmc_resource_switch`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `resource_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '编码',
  `is_abled` bit(1) NOT NULL COMMENT '开关',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '资源开关表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_resource_switch
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_statistical_policy
-- ----------------------------
DROP TABLE IF EXISTS `rmc_statistical_policy`;
CREATE TABLE `rmc_statistical_policy`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键ID，唯标识',
  `policy_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '策略名称',
  `policy_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '策略编码',
  `source_log` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '统计来源日志标志',
  `statistical_storetable` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '统计结果存储表',
  `query_field` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '查找字段，多个字段用逗号隔开',
  `statistical_field` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '统计字段',
  `statistical_mode` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '统计方式 1求和 2求平均数 3求最大值 4求最小值',
  `filter_condition_exp` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '过滤条件表达式',
  `filter_condition_field` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '过滤条件字段',
  `expire_date` int(11) NULL DEFAULT NULL COMMENT '统计有效时长（以“天”为单位）',
  `policy_desc` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '策略描述',
  `statistical_policy_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态0无效 1有效',
  `value_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '取值类型 0通过统计字段 1固定取值）',
  `fixed_value` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '固定值，在value_type=1时使用',
  `detail_statistical_storetable` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '详细统计结果存储表',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '风险管控统计策略配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_statistical_policy
-- ----------------------------
INSERT INTO `rmc_statistical_policy` VALUES ('948305080830443520', '浏览器登录次数策略', '001', 'loginLog', 'rmc_user_browser', 'user_sn', 'browser', '2', 'userSn!=null', 'userSn', 120, '', '1', '0', '1', 'rmc_user_browser_statistical');
INSERT INTO `rmc_statistical_policy` VALUES ('948305080830443526', 'ip策略', '002', 'loginLog', 'rmc_user_ip', 'user_sn', 'ip', '1', 'userSn!=null', 'userSn', 60, '', '1', '0', '2', 'rmc_user_ip_statistical');
INSERT INTO `rmc_statistical_policy` VALUES ('948305080830443588', '用户登录认证', '004', 'loginLog', 'rmc_user_login', 'user_sn', 'ip', '1', 'userSn!=null', 'ip', 30, NULL, '0', '1', '2', 'rmc_user_login_statistical');
INSERT INTO `rmc_statistical_policy` VALUES ('951930320447033344', '操作系统统计策略', '003', 'loginLog', 'rmc_user_system', 'user_sn', 'system', '1', 'userSn!=null', 'userSn', 5, NULL, '1', '1', '1', 'rmc_user_system_statistical');
INSERT INTO `rmc_statistical_policy` VALUES ('954427277049311232', '城市策略', 'CL004', 'loginLog', 'rmc_user_city', 'user_sn', 'city', NULL, 'userSn!=null', 'userSn', 60, NULL, '1', '1', '1', 'rmc_user_city_statistical');
INSERT INTO `rmc_statistical_policy` VALUES ('954478536376963072', '失败次数清零策略', 'CL006', 'loginLog', 'rmc_user_auth', 'user_sn', 'user_sn', '5', 'userSn!=null', 'userSn', 30, NULL, '1', '0', '1', 'rmc_user_auth_statistical');
INSERT INTO `rmc_statistical_policy` VALUES ('954737426364346368', '手机系统', 'CL007', 'loginLog', 'rmc_user_phonetype', 'user_sn', 'type', NULL, 'userSn!=null', 'userSn', 10, NULL, '1', '1', '1', 'rmc_user_phonetype_statistical');
INSERT INTO `rmc_statistical_policy` VALUES ('954770347816071168', '手机唯一标识策略', 'CL008', 'loginLog', 'rmc_user_phoneidentifier', 'user_sn', 'identifier', NULL, 'userSn!=null', 'userSn', 20, NULL, '1', '1', '1', 'rmc_user_phoneidentifier_statistical');

-- ----------------------------
-- Table structure for rmc_user
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user`;
CREATE TABLE `rmc_user`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '账号',
  `password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码',
  `telephone` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号 ',
  `real_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '真实姓名',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_user_auth
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_auth`;
CREATE TABLE `rmc_user_auth`  (
  `id` int(11) NOT NULL COMMENT '唯一标识',
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户编码',
  `count` float NULL DEFAULT NULL COMMENT '次数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户登录失败次数日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_auth
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_user_auth_statistical
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_auth_statistical`;
CREATE TABLE `rmc_user_auth_statistical`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '唯一标识',
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户编码',
  `count` float NULL DEFAULT NULL COMMENT '次数',
  `expire_date` timestamp NULL DEFAULT NULL COMMENT '到期时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户登录次数详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_auth_statistical
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_user_browser
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_browser`;
CREATE TABLE `rmc_user_browser`  (
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户编码',
  `count` float(12, 2) NOT NULL DEFAULT 0.00 COMMENT '值',
  `browser` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '浏览器类型',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户浏览器' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_browser
-- ----------------------------
INSERT INTO `rmc_user_browser` VALUES ('zahngmazi', 0.00, 'IE13', '954816318658785280');

-- ----------------------------
-- Table structure for rmc_user_browser_statistical
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_browser_statistical`;
CREATE TABLE `rmc_user_browser_statistical`  (
  `user_sn` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户编码',
  `browser` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '浏览器类型',
  `expire_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '到期时间',
  `count` float(12, 2) NOT NULL COMMENT '计数',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键 唯一标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '浏览器详细统计信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_browser_statistical
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_user_city
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_city`;
CREATE TABLE `rmc_user_city`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '唯一标识',
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户编码',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '城市 ',
  `count` float(12, 2) NULL DEFAULT NULL COMMENT '计数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户城市统计 ' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_city
-- ----------------------------
INSERT INTO `rmc_user_city` VALUES ('954804525478215680', 'zahngmazi', 'ShangHai', 10.00);

-- ----------------------------
-- Table structure for rmc_user_city_statistical
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_city_statistical`;
CREATE TABLE `rmc_user_city_statistical`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '唯一标识',
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户编码',
  `count` float(12, 2) NULL DEFAULT NULL COMMENT '计数',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '城市',
  `expire_date` timestamp NULL DEFAULT NULL COMMENT '到期时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户城市统计详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_city_statistical
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_user_ip
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_ip`;
CREATE TABLE `rmc_user_ip`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '唯一标识',
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户编码',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ip地址',
  `count` float(12, 2) NULL DEFAULT NULL COMMENT '计数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户IP统计 ' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_ip
-- ----------------------------
INSERT INTO `rmc_user_ip` VALUES ('954804523880185856', 'zahngmazi', '198.198.198.12', 24.00);

-- ----------------------------
-- Table structure for rmc_user_ip_statistical
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_ip_statistical`;
CREATE TABLE `rmc_user_ip_statistical`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '唯一标识',
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户编码',
  `count` float(12, 2) NULL DEFAULT NULL COMMENT '计数',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ip地址',
  `expire_date` timestamp NULL DEFAULT NULL COMMENT '到期时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户IP统计详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_ip_statistical
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_user_login_log
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_login_log`;
CREATE TABLE `rmc_user_login_log`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `user_sn` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `user_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `user_pwd` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `obj_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sex` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `telephone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `work_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `email` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `user_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `status` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户登录日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_login_log
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_user_phoneidentifier
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_phoneidentifier`;
CREATE TABLE `rmc_user_phoneidentifier`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '唯一标识',
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户编码',
  `count` float NULL DEFAULT NULL COMMENT '次数',
  `identifier` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '唯一标识符',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户手机唯一标识符统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_phoneidentifier
-- ----------------------------
INSERT INTO `rmc_user_phoneidentifier` VALUES ('954804526816198656', 'zahngmazi', 2, 'asdasdasdadasdasdasd');
INSERT INTO `rmc_user_phoneidentifier` VALUES ('954815866437316608', 'zahngmazi', 7, 'HUAWEIadsfasdfasdfads123');

-- ----------------------------
-- Table structure for rmc_user_phoneidentifier_statistical
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_phoneidentifier_statistical`;
CREATE TABLE `rmc_user_phoneidentifier_statistical`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '唯一标识符',
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户编码',
  `identifier` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '唯一标识符',
  `count` float NULL DEFAULT NULL COMMENT '次数',
  `expire_date` timestamp NULL DEFAULT NULL COMMENT '到期时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户手机唯一标识详情统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_phoneidentifier_statistical
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_user_phonetype
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_phonetype`;
CREATE TABLE `rmc_user_phonetype`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '唯一标识',
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户编码',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机品牌（类型）',
  `count` float NULL DEFAULT NULL COMMENT '计数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户手机类型统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_phonetype
-- ----------------------------
INSERT INTO `rmc_user_phonetype` VALUES ('954815865569095680', 'zahngmazi', 'HUAWEIc8815', 7);

-- ----------------------------
-- Table structure for rmc_user_phonetype_statistical
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_phonetype_statistical`;
CREATE TABLE `rmc_user_phonetype_statistical`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '唯一标识',
  `count` float NULL DEFAULT NULL COMMENT '计数',
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户编码',
  `expire_date` timestamp NULL DEFAULT NULL COMMENT '时间',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户手机类型详情统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_phonetype_statistical
-- ----------------------------

-- ----------------------------
-- Table structure for rmc_user_system
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_system`;
CREATE TABLE `rmc_user_system`  (
  `user_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户编码',
  `count` float(12, 2) NOT NULL DEFAULT 0.00 COMMENT '值',
  `system` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '操作系统类型',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户操作系统统计' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_system
-- ----------------------------
INSERT INTO `rmc_user_system` VALUES ('zahngmazi', 10.00, 'Windows10', '954804524677103616');

-- ----------------------------
-- Table structure for rmc_user_system_statistical
-- ----------------------------
DROP TABLE IF EXISTS `rmc_user_system_statistical`;
CREATE TABLE `rmc_user_system_statistical`  (
  `user_sn` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户编码',
  `system` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '操作系统类型',
  `expire_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '到期时间',
  `count` float(12, 2) NOT NULL COMMENT '计数',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键 唯一标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '操作系统详细统计信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rmc_user_system_statistical
-- ----------------------------

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `label` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '字典标签',
  `key_value` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '字典键值',
  `sort` int(11) NOT NULL COMMENT '排序',
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述',
  `dict_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '对应的字典类型',
  `status` bit(1) NOT NULL DEFAULT b'1' COMMENT '状态',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典详情表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES ('952368689781608448', '正常', '1', 1, '数据状态正常', 'currencyStauts', b'1', '2021-09-16 22:51:56');
INSERT INTO `sys_dict_data` VALUES ('952368749013839872', '停用', '0', 2, '数据状态停用', 'currencyStauts', b'1', '2021-09-16 10:52:10');
INSERT INTO `sys_dict_data` VALUES ('952526257829527552', '登录风险', 'loginLog', 1, '用户登录成功后进行信息统计', 'sourceKey', b'1', '2021-09-17 09:18:03');
INSERT INTO `sys_dict_data` VALUES ('952526389925072896', '认证风险', 'authLog', 2, '用户登录统计失败次数', 'sourceKey', b'1', '2021-09-17 09:18:35');
INSERT INTO `sys_dict_data` VALUES ('952567842135576576', '求和', 'sum', 1, NULL, 'statisticalMethod', b'1', '2021-09-17 12:03:17');
INSERT INTO `sys_dict_data` VALUES ('952975870313390080', 'sql类型', '0', 1, NULL, 'riskStrategyType', b'1', '2021-09-18 03:04:39');
INSERT INTO `sys_dict_data` VALUES ('953060172016037888', '固定字段', '1', 2, NULL, 'riskStrategyType', b'1', '2021-09-18 20:39:38');
INSERT INTO `sys_dict_data` VALUES ('953644863744704512', '2021-09-20', 'time1', 1, NULL, 'notLoginTime', b'1', '2021-09-20 11:22:59');
INSERT INTO `sys_dict_data` VALUES ('953685058754932736', '黑名单', 'BLACK', 1, NULL, 'blackWhiteType', b'1', '2021-09-20 14:02:43');
INSERT INTO `sys_dict_data` VALUES ('953685127357644800', '白名单', 'WHITE', 2, NULL, 'blackWhiteType', b'1', '2021-09-20 14:02:59');
INSERT INTO `sys_dict_data` VALUES ('954468917075066880', '求和', '1', 1, '对统计字段就行求和', 'statisticalType', b'1', '2021-09-22 17:57:29');
INSERT INTO `sys_dict_data` VALUES ('954469107602542592', '求平均数', '2', 2, '对统计字段求最大值', 'statisticalType', b'1', '2021-09-22 17:58:14');
INSERT INTO `sys_dict_data` VALUES ('954469276837163008', '最大值', '3', 3, '对统计字段求最大值', 'statisticalType', b'1', '2021-09-22 17:58:55');
INSERT INTO `sys_dict_data` VALUES ('954469336811380736', '最小值', '4', 4, '对统计字段求最小值', 'statisticalType', b'1', '2021-09-22 17:59:09');
INSERT INTO `sys_dict_data` VALUES ('954469473521065984', '清零', '5', 5, '对统计字段进行清零操作', 'statisticalType', b'1', '2021-09-22 17:59:42');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '字段名称',
  `type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '字典类型',
  `status` bit(1) NOT NULL DEFAULT b'1' COMMENT '状态',
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES ('952342411171008512', '来源标识', 'sourceKey', b'1', '来源标识类型', '2021-09-16 21:07:31');
INSERT INTO `sys_dict_type` VALUES ('952368599500161024', '公用的数据状态', 'currencyStauts', b'1', '公用的数据状态', '2021-09-16 22:51:34');
INSERT INTO `sys_dict_type` VALUES ('952567752925843456', '统计方式', 'statisticalMethod', b'1', '统计的不同方式', '2021-09-17 12:02:56');
INSERT INTO `sys_dict_type` VALUES ('952975766981840896', '风险策略类型', 'riskStrategyType', b'1', '风险策略配置的风险类型', '2021-09-18 15:04:14');
INSERT INTO `sys_dict_type` VALUES ('953644585642594304', '非工作时间登录', 'notLoginTime', b'1', '非工作时间登录', '2021-09-20 11:21:53');
INSERT INTO `sys_dict_type` VALUES ('953685000585076736', '黑白名单类型', 'blackWhiteType', b'1', '黑白名单类型', '2021-09-20 14:02:29');
INSERT INTO `sys_dict_type` VALUES ('954468593606283264', '统计方式', 'statisticalType', b'1', '统计类型', '2021-09-22 05:56:12');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `icon` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '图标',
  `menu_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单名',
  `url` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '路由路径',
  `parent_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '上级ID',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统菜单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标题',
  `method` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '请求方法',
  `request_method` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '请求方式',
  `oper_url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求地址 ',
  `oper_params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '请求参数',
  `json_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '返回参数',
  `status` tinyint(1) NOT NULL COMMENT '操作状态',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '错误消息 ',
  `oper_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '操作日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES ('1014930481540460544', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"lisi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\r\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'Unable to connect to Redis; nested exception is io.lettuce.core.RedisConnectionException: Unable to connect to 127.0.0.1:6379', '2022-03-08 14:10:09');
INSERT INTO `sys_oper_log` VALUES ('1014931146819719168', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\r\n    \"userSn\": \"lisi\",\r\n    \"browser\": \"IE13\",\r\n    \"ip\": \"198.198.198.12\",\r\n    \"city\": \"ShangHai\",\r\n    \"phoneType\": \"\",\r\n    \"phoneIdentifier\": \"asdasdasdadasdasdasd\",\r\n    \"system\": \"Windows10\"\r\n} resoucs001', 'null', 0, 'Unable to connect to Redis; nested exception is io.lettuce.core.RedisConnectionException: Unable to connect to 127.0.0.1:6379', '2022-03-08 14:12:48');
INSERT INTO `sys_oper_log` VALUES ('1014931664486268928', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\r\n    \"userSn\": \"lisi\",\r\n    \"browser\": \"IE13\",\r\n    \"ip\": \"198.198.198.12\",\r\n    \"city\": \"ShangHai\",\r\n    \"phoneType\": \"\",\r\n    \"phoneIdentifier\": \"asdasdasdadasdasdasd\",\r\n    \"system\": \"Windows10\"\r\n} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[7]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2022-03-08 14:14:51');
INSERT INTO `sys_oper_log` VALUES ('1014931803204485120', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\r\n    \"userSn\": \"lisi\",\r\n    \"browser\": \"IE13\",\r\n    \"ip\": \"198.198.198.12\",\r\n    \"city\": \"ShangHai\",\r\n    \"phoneType\": \"\",\r\n    \"phoneIdentifier\": \"asdasdasdadasdasdasd\",\r\n    \"system\": \"Windows10\"\r\n} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[7]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2022-03-08 14:15:24');
INSERT INTO `sys_oper_log` VALUES ('952924424443252736', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"lisi\",\"userName\":\"李四\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-18 16:42:47');
INSERT INTO `sys_oper_log` VALUES ('953643655790157824', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"lisi\",\"userName\":\"李四\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', 'null', 0, 'params 1 is null', '2021-09-20 11:18:10');
INSERT INTO `sys_oper_log` VALUES ('953645122187706368', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"lisi\",\"userName\":\"李四\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-20 11:24:00');
INSERT INTO `sys_oper_log` VALUES ('953647524156960768', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"lisi\",\"userName\":\"李四\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-20 11:33:33');
INSERT INTO `sys_oper_log` VALUES ('954353321084829696', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zhangsan\",\"userName\":\"张三\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[0]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:18:08');
INSERT INTO `sys_oper_log` VALUES ('954353480875229184', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zhangsan\",\"userName\":\"张三\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[0]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:18:46');
INSERT INTO `sys_oper_log` VALUES ('954354870016675840', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zhangsan\",\"userName\":\"张三\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:24:17');
INSERT INTO `sys_oper_log` VALUES ('954355233627922432', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zhangsan\",\"userName\":\"张三\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[9]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:25:44');
INSERT INTO `sys_oper_log` VALUES ('954355289345056768', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"lisi\",\"userName\":\"张三\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[0]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:25:57');
INSERT INTO `sys_oper_log` VALUES ('954355402172239872', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:26:24');
INSERT INTO `sys_oper_log` VALUES ('954357106699231232', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:33:10');
INSERT INTO `sys_oper_log` VALUES ('954357219509231616', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:33:37');
INSERT INTO `sys_oper_log` VALUES ('954358791899275264', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:39:52');
INSERT INTO `sys_oper_log` VALUES ('954358891820179456', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:40:16');
INSERT INTO `sys_oper_log` VALUES ('954359227419025408', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:41:36');
INSERT INTO `sys_oper_log` VALUES ('954359269098635264', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:41:46');
INSERT INTO `sys_oper_log` VALUES ('954359349926256640', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:42:05');
INSERT INTO `sys_oper_log` VALUES ('954359369057968128', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:42:10');
INSERT INTO `sys_oper_log` VALUES ('954359423067340800', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:42:23');
INSERT INTO `sys_oper_log` VALUES ('954359426679992320', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:42:23');
INSERT INTO `sys_oper_log` VALUES ('954359430381395968', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:42:24');
INSERT INTO `sys_oper_log` VALUES ('954360028135473152', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:44:47');
INSERT INTO `sys_oper_log` VALUES ('954360660530307072', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:47:18');
INSERT INTO `sys_oper_log` VALUES ('954361174581633024', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:49:20');
INSERT INTO `sys_oper_log` VALUES ('954361375271501824', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 10:50:08');
INSERT INTO `sys_oper_log` VALUES ('954431120482193408', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 15:27:17');
INSERT INTO `sys_oper_log` VALUES ('954431132222050304', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 15:27:19');
INSERT INTO `sys_oper_log` VALUES ('954431791235559424', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\",\"city\":\"南京\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 15:29:57');
INSERT INTO `sys_oper_log` VALUES ('954432184086519808', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"wangwu\",\"userName\":\"王五\",\"IP\":\"127.0.0.1\",\"browser\":\"IE8\",\"system\":\"windows\",\"city\":\"南京\"}\r\n\r\n\r\n 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1,2]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-22 15:31:30');
INSERT INTO `sys_oper_log` VALUES ('954800214916497408', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} 0001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 15:53:56');
INSERT INTO `sys_oper_log` VALUES ('954806154086002688', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:17:32');
INSERT INTO `sys_oper_log` VALUES ('954806190471454720', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:17:41');
INSERT INTO `sys_oper_log` VALUES ('954806482986680320', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:18:51');
INSERT INTO `sys_oper_log` VALUES ('954807433351430144', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:22:37');
INSERT INTO `sys_oper_log` VALUES ('954807444174491648', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:22:40');
INSERT INTO `sys_oper_log` VALUES ('954808114969260032', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:25:20');
INSERT INTO `sys_oper_log` VALUES ('954808140223569920', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:25:26');
INSERT INTO `sys_oper_log` VALUES ('954808240575946752', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:25:50');
INSERT INTO `sys_oper_log` VALUES ('954808743045853184', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:27:50');
INSERT INTO `sys_oper_log` VALUES ('954809676437471232', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'com.gelly.utils.ConvertToCodeUtils.convertToCode@1:24 parsing error near \'... unt=<10 ...\'', '2021-09-23 16:31:32');
INSERT INTO `sys_oper_log` VALUES ('954810588800065536', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'com.gelly.utils.ConvertToCodeUtils.convertToCode@1:24 parsing error near \'... unt=<10 ...\'', '2021-09-23 16:35:10');
INSERT INTO `sys_oper_log` VALUES ('954810627334897664', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:35:19');
INSERT INTO `sys_oper_log` VALUES ('954811285595729920', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:37:56');
INSERT INTO `sys_oper_log` VALUES ('954811300090433536', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:37:59');
INSERT INTO `sys_oper_log` VALUES ('954811308744228864', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:38:01');
INSERT INTO `sys_oper_log` VALUES ('954811416360464384', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:38:27');
INSERT INTO `sys_oper_log` VALUES ('954812068529950720', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[1]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:41:03');
INSERT INTO `sys_oper_log` VALUES ('954812167405797376', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[3]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 16:41:26');
INSERT INTO `sys_oper_log` VALUES ('954827565216825344', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[3]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-23 17:42:37');
INSERT INTO `sys_oper_log` VALUES ('954828145539100672', '日志统计', 'com.gelly.controller.external.StatisticsController.statisticsResourceInfo()', 'POST', '/risk-api/context/Statistics/statisticsResourceInfo', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} loginLog', 'null', 1, NULL, '2021-09-23 17:44:56');
INSERT INTO `sys_oper_log` VALUES ('955064797213429760', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'java.lang.String cannot be cast to java.lang.Boolean', '2021-09-24 09:25:18');
INSERT INTO `sys_oper_log` VALUES ('955064977241346048', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'java.lang.String cannot be cast to java.lang.Boolean', '2021-09-24 09:26:00');
INSERT INTO `sys_oper_log` VALUES ('955065028554731520', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'java.lang.String cannot be cast to java.lang.Boolean', '2021-09-24 09:26:13');
INSERT INTO `sys_oper_log` VALUES ('955065129142259712', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'java.lang.String cannot be cast to java.lang.Boolean', '2021-09-24 09:26:37');
INSERT INTO `sys_oper_log` VALUES ('955067031025864704', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'java.lang.String cannot be cast to java.lang.Boolean', '2021-09-24 09:34:10');
INSERT INTO `sys_oper_log` VALUES ('955067226245550080', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'java.lang.String cannot be cast to java.lang.Boolean', '2021-09-24 09:34:57');
INSERT INTO `sys_oper_log` VALUES ('955067288531779584', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'java.lang.String cannot be cast to java.lang.Boolean', '2021-09-24 09:35:12');
INSERT INTO `sys_oper_log` VALUES ('955067588050407424', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'java.lang.String cannot be cast to java.lang.Boolean', '2021-09-24 09:36:23');
INSERT INTO `sys_oper_log` VALUES ('955067732944265216', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'java.lang.String cannot be cast to java.lang.Boolean', '2021-09-24 09:36:58');
INSERT INTO `sys_oper_log` VALUES ('955068995970023424', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'java.lang.String cannot be cast to java.lang.Boolean', '2021-09-24 09:41:59');
INSERT INTO `sys_oper_log` VALUES ('955069249797799936', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', 'null', 0, 'java.lang.String cannot be cast to java.lang.Boolean', '2021-09-24 09:42:59');
INSERT INTO `sys_oper_log` VALUES ('955069348437544960', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-24 09:43:23');
INSERT INTO `sys_oper_log` VALUES ('955069631853027328', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-24 09:44:30');
INSERT INTO `sys_oper_log` VALUES ('955069849352314880', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-24 09:45:22');
INSERT INTO `sys_oper_log` VALUES ('955070625493790720', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[3]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-24 09:48:27');
INSERT INTO `sys_oper_log` VALUES ('955070997801185280', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[3]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-24 09:49:56');
INSERT INTO `sys_oper_log` VALUES ('955071124030660608', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[3]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-24 09:50:26');
INSERT INTO `sys_oper_log` VALUES ('955071266484105216', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"zahngmazi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[6]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-24 09:51:00');
INSERT INTO `sys_oper_log` VALUES ('955072451725144064', '风险分析', 'com.gelly.controller.external.ExternalConttroller.loginAnalysisRiskManage()', 'POST', '/risk-api/context/externalRisk/loginAnalysisRiskManage', '{\"userSn\":\"lisi\",\"browser\":\"IE13\",\"ip\":\"198.198.198.12\",\"city\":\"ShangHai\",\n\"phoneType\":\"\",\"phoneIdentifier\":\"asdasdasdadasdasdasd\",\"system\":\"Windows10\"} resoucs001', '{\"code\":200,\"data\":{\"accessPolicy\":[\"[7]\"]},\"message\":\"成功\",\"success\":true}', 1, NULL, '2021-09-24 09:55:43');

-- ----------------------------
-- Table structure for sys_params
-- ----------------------------
DROP TABLE IF EXISTS `sys_params`;
CREATE TABLE `sys_params`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `sign` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '唯一标识 ',
  `value` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '参数值  ',
  `descption` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述',
  `status` bit(1) NOT NULL DEFAULT b'1' COMMENT '状态 0：停用 1：正常',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统参数' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_params
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
