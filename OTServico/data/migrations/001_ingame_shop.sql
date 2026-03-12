-- Migration: Ingame Shop (client opcode 201)
-- Run this once. If a column/table already exists, ignore the corresponding error.
-- Uses: accounts.premium_points, z_shop_category, z_shop_offer, z_shop_history_item
-- Your database.sql/resetado.sql may already include these; run only what is missing.

-- 1) Ensure accounts has premium_points (currency for ingame shop)
-- Skip if you already have this column (e.g. duplicate column error):
ALTER TABLE `accounts` ADD COLUMN `premium_points` INT(11) NOT NULL DEFAULT 0;

-- 2) Create shop tables only if missing (run the block below only if you don't have these tables)
-- If you already have z_shop_category, z_shop_offer, z_shop_history_item from a website shop, skip this section.

/*
CREATE TABLE IF NOT EXISTS `z_shop_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `desc` varchar(255) NOT NULL DEFAULT '',
  `button` varchar(50) NOT NULL DEFAULT '',
  `hide` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `z_shop_offer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` int(3) NOT NULL,
  `coins` int(11) NOT NULL DEFAULT 0,
  `price` varchar(50) NOT NULL DEFAULT '',
  `itemid` int(11) NOT NULL DEFAULT 0,
  `mount_id` varchar(100) NOT NULL DEFAULT '',
  `addon_name` varchar(100) NOT NULL DEFAULT '',
  `count` int(11) NOT NULL DEFAULT 1,
  `offer_type` varchar(255) DEFAULT NULL,
  `offer_description` text,
  `offer_name` varchar(255) NOT NULL,
  `offer_date` int(11) NOT NULL DEFAULT 0,
  `default_image` varchar(50) NOT NULL DEFAULT '',
  `hide` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `z_shop_history_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `to_name` varchar(255) NOT NULL DEFAULT '',
  `to_account` int(11) NOT NULL DEFAULT 0,
  `from_nick` varchar(255) NOT NULL DEFAULT '',
  `from_account` int(11) NOT NULL DEFAULT 0,
  `price` int(11) NOT NULL DEFAULT 0,
  `offer_id` int(11) NOT NULL DEFAULT 0,
  `trans_state` varchar(255) NOT NULL DEFAULT '',
  `trans_start` int(11) NOT NULL DEFAULT 0,
  `trans_real` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
*/

-- 3) Example: insert a test category and offer (optional – for validation)
-- INSERT INTO `z_shop_category` (`name`, `desc`, `button`, `hide`) VALUES ('Items', 'Buy items with premium points.', '_sbutton_getextraservice.gif', 0);
-- SET @cat_id = LAST_INSERT_ID();
-- INSERT INTO `z_shop_offer` (`category`, `coins`, `price`, `itemid`, `count`, `offer_type`, `offer_description`, `offer_name`, `offer_date`, `default_image`, `hide`) VALUES (@cat_id, 5, '', 2160, 100, 'items', '100 gold coins.', '100 Gold Coins', UNIX_TIMESTAMP(), '', 0);
