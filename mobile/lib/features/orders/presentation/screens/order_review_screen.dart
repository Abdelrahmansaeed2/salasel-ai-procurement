import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/animated_entrance.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../domain/order_review_models.dart';
import '../controllers/order_review_controller.dart';
import '../theme/order_colors.dart';
import 'order_success_screen.dart';

const String _avatarUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/c7070914a8d0a025b8aab03d2f42684260d4b530?width=72';

const List<String> _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

String _toArabicNumerals(int value) =>
    value.toString().split('').map((d) => _arabicDigits[int.parse(d)]).join();

class _Icons {
  static const helpBadge =
      '<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M9.95 16C10.3 16 10.5958 15.8792 10.8375 15.6375C11.0792 15.3958 11.2 15.1 11.2 14.75C11.2 14.4 11.0792 14.1042 10.8375 13.8625C10.5958 13.6208 10.3 13.5 9.95 13.5C9.6 13.5 9.30417 13.6208 9.0625 13.8625C8.82083 14.1042 8.7 14.4 8.7 14.75C8.7 15.1 8.82083 15.3958 9.0625 15.6375C9.30417 15.8792 9.6 16 9.95 16ZM9.05 12.15H10.9C10.9 11.6 10.9625 11.1667 11.0875 10.85C11.2125 10.5333 11.5667 10.1 12.15 9.55C12.5833 9.11667 12.925 8.70417 13.175 8.3125C13.425 7.92083 13.55 7.45 13.55 6.9C13.55 5.96667 13.2083 5.25 12.525 4.75C11.8417 4.25 11.0333 4 10.1 4C9.15 4 8.37917 4.25 7.7875 4.75C7.19583 5.25 6.78333 5.85 6.55 6.55L8.2 7.2C8.28333 6.9 8.47083 6.575 8.7625 6.225C9.05417 5.875 9.5 5.7 10.1 5.7C10.6333 5.7 11.0333 5.84583 11.3 6.1375C11.5667 6.42917 11.7 6.75 11.7 7.1C11.7 7.43333 11.6 7.74583 11.4 8.0375C11.2 8.32917 10.95 8.6 10.65 8.85C9.91667 9.5 9.46667 9.99167 9.3 10.325C9.13333 10.6583 9.05 11.2667 9.05 12.15ZM10 20C8.61667 20 7.31667 19.7375 6.1 19.2125C4.88333 18.6875 3.825 17.975 2.925 17.075C2.025 16.175 1.3125 15.1167 0.7875 13.9C0.2625 12.6833 0 11.3833 0 10C0 8.61667 0.2625 7.31667 0.7875 6.1C1.3125 4.88333 2.025 3.825 2.925 2.925C3.825 2.025 4.88333 1.3125 6.1 0.7875C7.31667 0.2625 8.61667 0 10 0C11.3833 0 12.6833 0.2625 13.9 0.7875C15.1167 1.3125 16.175 2.025 17.075 2.925C17.975 3.825 18.6875 4.88333 19.2125 6.1C19.7375 7.31667 20 8.61667 20 10C20 11.3833 19.7375 12.6833 19.2125 13.9C18.6875 15.1167 17.975 16.175 17.075 17.075C16.175 17.975 15.1167 18.6875 13.9 19.2125C12.6833 19.7375 11.3833 20 10 20ZM10 18C12.2333 18 14.125 17.225 15.675 15.675C17.225 14.125 18 12.2333 18 10C18 7.76667 17.225 5.875 15.675 4.325C14.125 2.775 12.2333 2 10 2C7.76667 2 5.875 2.775 4.325 4.325C2.775 5.875 2 7.76667 2 10C2 12.2333 2.775 14.125 4.325 15.675C5.875 17.225 7.76667 18 10 18Z" fill="#434655"/></svg>';

  static const backArrow =
      '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M12.175 9H0V7H12.175L6.575 1.4L8 0L16 8L8 16L6.575 14.6L12.175 9Z" fill="#333333"/></svg>';

  static const transcript =
      '<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M6 1C6.39782 1 6.77936 1.15804 7.06066 1.43934C7.34196 1.72064 7.5 2.10218 7.5 2.5V6C7.5 6.39782 7.34196 6.77936 7.06066 7.06066C6.77936 7.34196 6.39782 7.5 6 7.5C5.60218 7.5 5.22064 7.34196 4.93934 7.06066C4.65804 6.77936 4.5 6.39782 4.5 6V2.5C4.5 2.10218 4.65804 1.72064 4.93934 1.43934C5.22064 1.15804 5.60218 1 6 1Z" stroke="#90A1B9" stroke-width="1.25" stroke-linecap="round"/>'
      '<path d="M9.5 5V6C9.5 6.92826 9.13125 7.8185 8.47487 8.47487C7.8185 9.13125 6.92826 9.5 6 9.5C5.07174 9.5 4.1815 9.13125 3.52513 8.47487C2.86875 7.8185 2.5 6.92826 2.5 6V5" stroke="#90A1B9" stroke-width="1.25" stroke-linecap="round"/>'
      '<path d="M6 9.5V11.5" stroke="#90A1B9" stroke-width="1.25" stroke-linecap="round"/>'
      '<path d="M4 11.5H8" stroke="#90A1B9" stroke-width="1.25" stroke-linecap="round"/></svg>';

  static String pencil(String color) =>
      '<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M6 10H10.5" stroke="$color" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M8.18799 1.81087C8.38703 1.61182 8.657 1.5 8.93849 1.5C9.21998 1.5 9.48994 1.61182 9.68899 1.81087C9.88803 2.00991 9.99986 2.27988 9.99986 2.56137C9.99986 2.84286 9.88803 3.11282 9.68899 3.31187L3.68399 9.31737C3.56504 9.43632 3.418 9.52333 3.25649 9.57037L1.82049 9.98937C1.77746 10.0019 1.73186 10.0027 1.68844 9.99155C1.64503 9.98042 1.6054 9.95783 1.57371 9.92614C1.54202 9.89445 1.51943 9.85483 1.50831 9.81141C1.49719 9.768 1.49794 9.72239 1.51049 9.67937L1.92949 8.24337C1.9766 8.08203 2.06361 7.93518 2.18249 7.81637L8.18799 1.81087Z" stroke="$color" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const sparkle =
      '<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M5.76248 1.14745C5.7844 1.10318 5.81824 1.06591 5.86021 1.03986C5.90218 1.01381 5.95059 1 5.99998 1C6.04938 1 6.09779 1.01381 6.13976 1.03986C6.18172 1.06591 6.21557 1.10318 6.23748 1.14745L7.39248 3.48695C7.46857 3.64093 7.58089 3.77415 7.7198 3.87517C7.8587 3.9762 8.02005 4.042 8.18998 4.06695L10.773 4.44495C10.8219 4.45204 10.8679 4.47268 10.9057 4.50455C10.9435 4.53641 10.9717 4.57822 10.987 4.62525C11.0023 4.67228 11.0041 4.72265 10.9923 4.77066C10.9804 4.81868 10.9554 4.86242 10.92 4.89695L9.05198 6.71595C8.92879 6.836 8.83662 6.98419 8.7834 7.14776C8.73018 7.31133 8.71751 7.48539 8.74648 7.65495L9.18748 10.2249C9.19612 10.2739 9.19084 10.3242 9.17223 10.3703C9.15363 10.4163 9.12245 10.4563 9.08226 10.4854C9.04206 10.5146 8.99447 10.5319 8.94492 10.5354C8.89536 10.5388 8.84583 10.5283 8.80198 10.5049L6.49298 9.29095C6.34084 9.21106 6.17157 9.16932 5.99973 9.16932C5.82789 9.16932 5.65863 9.21106 5.50648 9.29095L3.19798 10.5049C3.15415 10.5282 3.10468 10.5386 3.05521 10.5351C3.00574 10.5316 2.95824 10.5142 2.91813 10.4851C2.87802 10.4559 2.8469 10.416 2.82831 10.3701C2.80972 10.3241 2.80441 10.2738 2.81298 10.2249L3.25348 7.65545C3.28258 7.48581 3.26998 7.31165 3.21675 7.14797C3.16353 6.98429 3.07129 6.83602 2.94798 6.71595L1.07998 4.89745C1.04428 4.86296 1.01898 4.81914 1.00697 4.77098C0.99495 4.72282 0.996703 4.67226 1.01202 4.62504C1.02734 4.57783 1.05562 4.53587 1.09362 4.50394C1.13163 4.47201 1.17784 4.4514 1.22698 4.44445L3.80948 4.06695C3.97961 4.0422 4.14118 3.97648 4.28028 3.87544C4.41937 3.77441 4.53184 3.64108 4.60798 3.48695L5.76248 1.14745Z" stroke="#2563EB" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const infoCircle =
      '<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M6 11C8.76142 11 11 8.76142 11 6C11 3.23858 8.76142 1 6 1C3.23858 1 1 3.23858 1 6C1 8.76142 3.23858 11 6 11Z" stroke="#90A1B9" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M6 8V6" stroke="#90A1B9" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M6 4H6.005" stroke="#90A1B9" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const shieldOutline =
      '<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M10 6.50022C10 9.00022 8.25 10.2502 6.17 10.9752C6.06108 11.0121 5.94277 11.0104 5.835 10.9702C3.75 10.2502 2 9.00022 2 6.50022V3.00022C2 2.86762 2.05268 2.74044 2.14645 2.64667C2.24021 2.5529 2.36739 2.50022 2.5 2.50022C3.5 2.50022 4.75 1.90022 5.62 1.14022C5.72593 1.04972 5.86068 1 6 1C6.13932 1 6.27407 1.04972 6.38 1.14022C7.255 1.90522 8.5 2.50022 9.5 2.50022C9.63261 2.50022 9.75979 2.5529 9.85355 2.64667C9.94732 2.74044 10 2.86762 10 3.00022V6.50022Z" stroke="#90A1B9" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M4.5 6L5.5 7L7.5 5" stroke="#90A1B9" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const plus =
      '<svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M2.91669 7H11.0834" stroke="#686C71" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M7 2.9165V11.0832" stroke="#686C71" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const starFilled =
      '<svg width="11" height="11" viewBox="0 0 11 11" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M5.28228 1.05166C5.30237 1.01108 5.3334 0.976924 5.37186 0.953042C5.41033 0.929159 5.45471 0.916504 5.49999 0.916504C5.54527 0.916504 5.58965 0.929159 5.62812 0.953042C5.66659 0.976924 5.69761 1.01108 5.7177 1.05166L6.77645 3.19621C6.8462 3.33736 6.94915 3.45948 7.07649 3.55208C7.20382 3.64468 7.35172 3.70501 7.50749 3.72787L9.87524 4.07437C9.9201 4.08087 9.96226 4.0998 9.99692 4.129C10.0316 4.15821 10.0574 4.19654 10.0714 4.23965C10.0854 4.28276 10.0871 4.32893 10.0763 4.37295C10.0654 4.41696 10.0424 4.45706 10.01 4.48871L8.29766 6.15612C8.18473 6.26617 8.10024 6.40201 8.05146 6.55195C8.00267 6.70189 7.99106 6.86145 8.01762 7.01687L8.42187 9.37271C8.42979 9.41755 8.42494 9.46371 8.40789 9.50594C8.39083 9.54816 8.36225 9.58473 8.32541 9.6115C8.28856 9.63826 8.24494 9.65412 8.19951 9.65728C8.15409 9.66044 8.10869 9.65077 8.06849 9.62937L5.95191 8.51654C5.81244 8.44331 5.65728 8.40505 5.49976 8.40505C5.34224 8.40505 5.18708 8.44331 5.04762 8.51654L2.93149 9.62937C2.89131 9.65064 2.84596 9.66021 2.80061 9.65699C2.75526 9.65377 2.71173 9.63788 2.67496 9.61114C2.63819 9.5844 2.60966 9.54788 2.59262 9.50572C2.57559 9.46357 2.57072 9.41749 2.57857 9.37271L2.98237 7.01733C3.00904 6.86183 2.99748 6.70218 2.9487 6.55214C2.89991 6.40211 2.81535 6.26619 2.70232 6.15612L0.989991 4.48916C0.957263 4.45755 0.934071 4.41739 0.923057 4.37324C0.912043 4.32909 0.913649 4.28274 0.927693 4.23946C0.941738 4.19618 0.967655 4.15772 1.00249 4.12845C1.03733 4.09918 1.07969 4.08028 1.12474 4.07391L3.49203 3.72787C3.64798 3.70518 3.79609 3.64494 3.92359 3.55232C4.0511 3.45971 4.15419 3.3375 4.22399 3.19621L5.28228 1.05166Z" fill="#FCD34D" stroke="#FFDF20" stroke-width="0.916667" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const starOutline =
      '<svg width="11" height="11" viewBox="0 0 11 11" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M5.28228 1.05166C5.30237 1.01108 5.3334 0.976924 5.37186 0.953042C5.41033 0.929159 5.45471 0.916504 5.49999 0.916504C5.54527 0.916504 5.58965 0.929159 5.62812 0.953042C5.66659 0.976924 5.69761 1.01108 5.7177 1.05166L6.77645 3.19621C6.8462 3.33736 6.94915 3.45948 7.07649 3.55208C7.20382 3.64468 7.35172 3.70501 7.50749 3.72787L9.87524 4.07437C9.92011 4.08087 9.96226 4.0998 9.99692 4.129C10.0316 4.15821 10.0574 4.19654 10.0714 4.23965C10.0854 4.28276 10.0871 4.32893 10.0763 4.37295C10.0654 4.41696 10.0424 4.45706 10.01 4.48871L8.29766 6.15612C8.18473 6.26617 8.10024 6.40201 8.05146 6.55195C8.00267 6.70189 7.99106 6.86145 8.01762 7.01687L8.42187 9.37271C8.42979 9.41755 8.42494 9.46371 8.40789 9.50594C8.39083 9.54816 8.36225 9.58473 8.32541 9.6115C8.28856 9.63826 8.24494 9.65412 8.19951 9.65728C8.15409 9.66044 8.10869 9.65077 8.06849 9.62937L5.95191 8.51654C5.81244 8.44331 5.65728 8.40505 5.49976 8.40505C5.34224 8.40505 5.18708 8.44331 5.04762 8.51654L2.93149 9.62937C2.89131 9.65064 2.84596 9.66021 2.80061 9.65699C2.75526 9.65377 2.71173 9.63788 2.67496 9.61114C2.63819 9.5844 2.60966 9.54787 2.59262 9.50572C2.57559 9.46357 2.57072 9.41749 2.57857 9.37271L2.98237 7.01733C3.00904 6.86183 2.99748 6.70218 2.9487 6.55214C2.89991 6.40211 2.81535 6.26619 2.70232 6.15612L0.989991 4.48916C0.957263 4.45755 0.934071 4.41739 0.923057 4.37324C0.912043 4.32909 0.913649 4.28274 0.927693 4.23946C0.941738 4.19618 0.967655 4.15772 1.00249 4.12845C1.03733 4.09918 1.07969 4.08028 1.12474 4.07391L3.49203 3.72787C3.64798 3.70518 3.79609 3.64494 3.92359 3.55232C4.0511 3.45971 4.15419 3.3375 4.22399 3.19621L5.28228 1.05166Z" stroke="white" stroke-opacity="0.3" stroke-width="0.916667" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const shippingBox =
      '<svg width="13" height="12" viewBox="0 0 13 12" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M7.58334 9.74984V3.24984C7.58334 2.96252 7.46921 2.68697 7.26604 2.4838C7.06288 2.28064 6.78733 2.1665 6.50001 2.1665H2.16668C1.87936 2.1665 1.60381 2.28064 1.40064 2.4838C1.19748 2.68697 1.08334 2.96252 1.08334 3.24984V9.20817C1.08334 9.35183 1.14041 9.48961 1.24199 9.59119C1.34358 9.69277 1.48135 9.74984 1.62501 9.74984H2.70834" stroke="#2563EB" stroke-width="1.08333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M8.125 9.75H4.875" stroke="#2563EB" stroke-width="1.08333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M10.2917 9.75016H11.375C11.5187 9.75016 11.6564 9.6931 11.758 9.59151C11.8596 9.48993 11.9167 9.35216 11.9167 9.2085V7.23141C11.9165 7.10849 11.8744 6.98929 11.7975 6.89341L9.91251 4.53716C9.86185 4.47372 9.79758 4.42248 9.72445 4.38723C9.65132 4.35198 9.5712 4.33361 9.49001 4.3335H7.58334" stroke="#2563EB" stroke-width="1.08333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M9.20833 10.8332C9.80664 10.8332 10.2917 10.3481 10.2917 9.74984C10.2917 9.15153 9.80664 8.6665 9.20833 8.6665C8.61002 8.6665 8.125 9.15153 8.125 9.74984C8.125 10.3481 8.61002 10.8332 9.20833 10.8332Z" stroke="#2563EB" stroke-width="1.08333" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M3.79168 10.8332C4.38999 10.8332 4.87501 10.3481 4.87501 9.74984C4.87501 9.15153 4.38999 8.6665 3.79168 8.6665C3.19337 8.6665 2.70834 9.15153 2.70834 9.74984C2.70834 10.3481 3.19337 10.8332 3.79168 10.8332Z" stroke="#2563EB" stroke-width="1.08333" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const checkCircle =
      '<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M6 11C8.76142 11 11 8.76142 11 6C11 3.23858 8.76142 1 6 1C3.23858 1 1 3.23858 1 6C1 8.76142 3.23858 11 6 11Z" stroke="#22C55E" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M4.5 6L5.5 7L7.5 5" stroke="#22C55E" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const shieldCheckSafe =
      '<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M12.5 8.12479C12.5 11.2498 10.3125 12.8123 7.7125 13.7185C7.57635 13.7647 7.42846 13.7625 7.29375 13.7123C4.6875 12.8123 2.5 11.2498 2.5 8.12479V3.74979C2.5 3.58403 2.56585 3.42506 2.68306 3.30785C2.80027 3.19064 2.95924 3.12479 3.125 3.12479C4.375 3.12479 5.9375 2.37479 7.025 1.42479C7.15741 1.31167 7.32585 1.24951 7.5 1.24951C7.67415 1.24951 7.84259 1.31167 7.975 1.42479C9.06875 2.38104 10.625 3.12479 11.875 3.12479C12.0408 3.12479 12.1997 3.19064 12.3169 3.30785C12.4342 3.42506 12.5 3.58403 12.5 3.74979V8.12479Z" stroke="#22C55E" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M5.625 7.5L6.875 8.75L9.375 6.25" stroke="#22C55E" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  static const warningTriangle =
      '<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M13.5813 11.2499L8.58127 2.4999C8.47224 2.30752 8.31414 2.14751 8.12309 2.03619C7.93205 1.92486 7.71488 1.86621 7.49377 1.86621C7.27265 1.86621 7.05549 1.92486 6.86444 2.03619C6.67339 2.14751 6.51529 2.30752 6.40627 2.4999L1.40627 11.2499C1.29607 11.4407 1.23828 11.6573 1.23877 11.8777C1.23926 12.0981 1.298 12.3144 1.40905 12.5048C1.52009 12.6951 1.67948 12.8528 1.87108 12.9617C2.06267 13.0706 2.27965 13.1269 2.50002 13.1249H12.5C12.7193 13.1247 12.9347 13.0668 13.1246 12.9569C13.3144 12.8471 13.472 12.6893 13.5816 12.4993C13.6911 12.3094 13.7488 12.0939 13.7487 11.8746C13.7487 11.6553 13.6909 11.4398 13.5813 11.2499Z" stroke="#F59E0B" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M7.5 5.625V8.125" stroke="#F59E0B" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M7.5 10.625H7.50625" stroke="#F59E0B" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/></svg>';
}

class OrderReviewScreen extends StatelessWidget {
  const OrderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderReviewController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      const AnimatedEntrance(
                        child: _SectionHeader(
                          iconSvg: _Icons.transcript,
                          iconSize: 12,
                          label: 'النص الصوتي الأصلي',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const AnimatedEntrance(
                        delay: Duration(milliseconds: 60),
                        child: _TranscriptCard(),
                      ),
                      const SizedBox(height: 24),
                      AnimatedEntrance(
                        delay: const Duration(milliseconds: 120),
                        child: _SectionHeader(
                          iconSvg: _Icons.pencil('#2563EB'),
                          iconSize: 12,
                          label: 'المنتجات المُستخرَجة',
                          color: OrderColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => Column(
                          children: [
                            for (int i = 0; i < controller.products.length; i++) ...[
                              AnimatedEntrance(
                                delay: Duration(milliseconds: 150 + i * 80),
                                beginOffset: const Offset(0.05, 0),
                                child: _ProductLineCard(index: i, controller: controller),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      ),
                      const AnimatedEntrance(
                        delay: Duration(milliseconds: 260),
                        child: _AddProductButton(),
                      ),
                      const SizedBox(height: 24),
                      const AnimatedEntrance(
                        delay: Duration(milliseconds: 300),
                        child: _SectionHeader(
                          iconSvg: _Icons.sparkle,
                          iconSize: 12,
                          label: 'توصية الذكاء الاصطناعي',
                          color: OrderColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const AnimatedEntrance(
                        delay: Duration(milliseconds: 350),
                        beginOffset: Offset(0, 0.12),
                        child: _SupplierRecommendationCard(),
                      ),
                      const SizedBox(height: 24),
                      const AnimatedEntrance(
                        delay: Duration(milliseconds: 420),
                        child: _SectionHeader(
                          iconSvg: _Icons.infoCircle,
                          iconSize: 12,
                          label: 'مستوى الثقة',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const AnimatedEntrance(
                        delay: Duration(milliseconds: 460),
                        child: _ConfidenceScoreCard(),
                      ),
                      const SizedBox(height: 24),
                      const AnimatedEntrance(
                        delay: Duration(milliseconds: 520),
                        child: _SectionHeader(
                          iconSvg: _Icons.shieldOutline,
                          iconSize: 12,
                          label: 'تحليل المخاطر',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          for (int i = 0; i < controller.riskAlerts.length; i++) ...[
                            AnimatedEntrance(
                              delay: Duration(milliseconds: 560 + i * 70),
                              beginOffset: const Offset(0.05, 0),
                              child: _RiskAlertTile(alert: controller.riskAlerts[i]),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      AnimatedEntrance(
                        delay: const Duration(milliseconds: 720),
                        child: _ConfirmButton(controller: controller),
                      ),
                      const SizedBox(height: 10),
                      const AnimatedEntrance(
                        delay: Duration(milliseconds: 760),
                        child: _SecondaryActionsRow(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xCCFAF8FF),
        boxShadow: [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDBE1FF), width: 2),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: _avatarUrl,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 300),
                  placeholder: (_, __) => const ColoredBox(color: Color(0xFFDBE1FF)),
                  errorWidget: (_, __, ___) => const ColoredBox(color: Color(0xFFDBE1FF)),
                ),
              ),
            ),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(999),
              onTap: () => Get.snackbar('مساعدة', 'راجع تفاصيل الطلب قبل التأكيد'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                child: SvgPicture.string(_Icons.helpBadge, width: 20, height: 20),
              ),
            ),
            const Spacer(),
            const Text(
              'مراجعة الطلب',
              style: TextStyle(
                color: Color(0xFF333333),
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(width: 12),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(999),
              onTap: () => Get.back(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                child: SvgPicture.string(_Icons.backArrow, width: 16, height: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String iconSvg;
  final double iconSize;
  final String label;
  final Color? color;

  const _SectionHeader({
    required this.iconSvg,
    required this.iconSize,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? OrderColors.sectionLabel;
    return Row(
      children: [
        SvgPicture.string(iconSvg, width: iconSize, height: iconSize),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: c,
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.96,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: OrderColors.divider, height: 1)),
      ],
    );
  }
}

class _TranscriptCard extends StatelessWidget {
  const _TranscriptCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderColors.transcriptBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: OrderColors.transcriptBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                ),
                child: SvgPicture.string(
                  '<svg width="14" height="16" viewBox="0 0 14 16" fill="none" xmlns="http://www.w3.org/2000/svg">'
                  '<path d="M10 3C10 1.34315 8.65685 0 7 0C5.34315 0 4 1.34315 4 3V6C4 7.65685 5.34315 9 7 9C8.65685 9 10 7.65685 10 6V3Z" fill="white"/>'
                  '<path d="M1 7C1 8.5913 1.63214 10.1174 2.75736 11.2426C3.88258 12.3679 5.4087 13 7 13C8.5913 13 10.1174 12.3679 11.2426 11.2426C12.3679 10.1174 13 8.5913 13 7" stroke="white" stroke-width="1.5" stroke-linecap="round"/>'
                  '<path d="M7 13V15.5" stroke="white" stroke-width="1.5" stroke-linecap="round"/>'
                  '<path d="M4.5 15.5H9.5" stroke="white" stroke-width="1.5" stroke-linecap="round"/></svg>',
                  width: 14,
                  height: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'أطلب عشرين كرتون مياه معدنية... واثنا عشر كرتون عصير...',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: OrderColors.textBody,
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('النص الكامل'),
                            content: const Text(
                              'أطلب عشرين كرتون مياه معدنية سعة نصف لتر، واثنا عشر كرتون عصير برتقال طبيعي بنكهة طبيعية.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('إغلاق'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'عرض النص الكامل',
                        style: TextStyle(
                          color: OrderColors.primary,
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const _StaticWaveform(),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: OrderColors.transcriptBorder, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text('٢ منتج مُستخرَج',
                  style: TextStyle(color: OrderColors.textFaint, fontFamily: 'Cairo', fontSize: 10)),
              SizedBox(width: 6),
              Text('•', style: TextStyle(color: OrderColors.textFaint, fontSize: 10)),
              SizedBox(width: 6),
              Text('مدة: ١٢ ث',
                  style: TextStyle(color: OrderColors.textFaint, fontFamily: 'Cairo', fontSize: 10)),
              SizedBox(width: 6),
              Text('•', style: TextStyle(color: OrderColors.textFaint, fontSize: 10)),
              SizedBox(width: 6),
              _RecognitionBadge(),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecognitionBadge extends StatelessWidget {
  const _RecognitionBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text('تم التعرف ٩٨٪',
            style: TextStyle(
                color: OrderColors.success,
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: FontWeight.w600)),
        SizedBox(width: 6),
        _Dot(color: OrderColors.success),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _StaticWaveform extends StatelessWidget {
  const _StaticWaveform();

  static const List<double> _heights = [14, 20, 10, 18, 24, 14, 8, 18];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final h in _heights)
            Container(
              width: 2,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: OrderColors.primaryDark.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductLineCard extends StatelessWidget {
  final int index;
  final OrderReviewController controller;

  const _ProductLineCard({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final product = controller.products[index];
      final isEditing = controller.editingIndex.value == index;
      return _buildCard(product, isEditing);
    });
  }

  Widget _buildCard(ExtractedProduct product, bool isEditing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: OrderColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x0A0F172A), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AnimatedPressable(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => controller.toggleEdit(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isEditing ? OrderColors.primarySoft : OrderColors.chipBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AnimatedRotation(
                      turns: isEditing ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: SvgPicture.string(
                        _Icons.pencil(isEditing ? '#2563EB' : '#62748E'),
                        width: 12,
                        height: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${product.total.toStringAsFixed(2)} ج',
                  style: const TextStyle(
                    color: OrderColors.textBody,
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: Text(
                    product.name,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF1D293D),
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: OrderColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: OrderColors.primary,
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${product.unitPrice.toStringAsFixed(2)} جنيه / ${product.unitLabel}'
                  '${product.note != null ? ' · ${product.note}' : ''}',
                  style: const TextStyle(
                    color: OrderColors.textFaint,
                    fontFamily: 'Cairo',
                    fontSize: 11,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: isEditing
                      ? _QuantityStepper(
                          key: const ValueKey('stepper'),
                          quantity: product.quantity,
                          onIncrement: () => controller.increment(index),
                          onDecrement: () => controller.decrement(index),
                        )
                      : Container(
                          key: const ValueKey('chip'),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: OrderColors.primarySoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${product.quantity} ${product.unitLabel}',
                            style: const TextStyle(
                              color: OrderColors.primary,
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepBtn(Icons.remove, onDecrement),
        SizedBox(
          width: 32,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: Text(
              '$quantity',
              key: ValueKey(quantity),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: OrderColors.primary,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
        _stepBtn(Icons.add, onIncrement),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: OrderColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: OrderColors.primary),
      ),
    );
  }
}

class _AddProductButton extends StatelessWidget {
  const _AddProductButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DottedBorderButton(
        onTap: () => Get.snackbar('إضافة منتج', 'اختر منتجاً لإضافته إلى الطلب'),
      ),
    );
  }
}

class DottedBorderButton extends StatelessWidget {
  final VoidCallback onTap;
  const DottedBorderButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBAC0C8), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(_Icons.plus, width: 14, height: 14),
            const SizedBox(width: 8),
            const Text(
              'إضافة منتج',
              style: TextStyle(
                color: Color(0xFF686C71),
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplierRecommendationCard extends StatelessWidget {
  const _SupplierRecommendationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F6FF), Color(0xFFF8FAFC)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: OrderColors.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'اختيار الذكاء الاصطناعي',
                  style: TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.string(_Icons.starFilled, width: 11, height: 11),
                SvgPicture.string(_Icons.starFilled, width: 11, height: 11),
                SvgPicture.string(_Icons.starFilled, width: 11, height: 11),
                SvgPicture.string(_Icons.starFilled, width: 11, height: 11),
                SvgPicture.string(_Icons.starOutline, width: 11, height: 11),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: OrderColors.primarySoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('🏭', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'الجوهرة للتوزيع',
                            style: TextStyle(
                              color: Color(0xFF0F172B),
                              fontFamily: 'Cairo',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '٤٢ طلب سابق • موثوق ٩٧٪',
                            style: TextStyle(
                              color: OrderColors.textMuted,
                              fontFamily: 'Cairo',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Expanded(
                      child: _StatChip(
                        value: '٧٢٪',
                        label: 'في الوقت',
                        color: OrderColors.primary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _StatChip(
                        value: 'غداً',
                        label: 'وقت التوصيل',
                        color: OrderColors.textTitle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _StatChip(
                        value: '٤٦١ ر.س',
                        label: 'السعر الإجمالي',
                        color: OrderColors.success,
                        footnote: 'أقل بـ ١١٪',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 0.72),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Row(
                      children: [
                        SvgPicture.string(_Icons.shippingBox, width: 13, height: 12),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation(OrderColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_toArabicNumerals((value * 100).round())}٪ في الوقت',
                          style: const TextStyle(
                            color: OrderColors.primary,
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final String? footnote;

  const _StatChip({
    required this.value,
    required this.label,
    required this.color,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xCCE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: OrderColors.textMuted,
              fontFamily: 'Cairo',
              fontSize: 9,
            ),
          ),
          if (footnote != null) ...[
            const SizedBox(height: 2),
            Text(
              footnote!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: OrderColors.textFaint,
                fontFamily: 'Cairo',
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfidenceScoreCard extends StatelessWidget {
  const _ConfidenceScoreCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: OrderColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 0.94),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 5,
                        valueColor: AlwaysStoppedAnimation(Color(0xFFF1F5F9)),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                        valueColor: const AlwaysStoppedAnimation(OrderColors.success),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    Text(
                      '${(value * 100).round()}%',
                      style: const TextStyle(
                        color: Color(0xFF0F172B),
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'ثقة الذكاء الاصطناعي',
                  style: TextStyle(
                    color: Color(0xFF1D293D),
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'التطابق دقيق جداً مع قواعد بيانات المنتجات والأسعار الحالية',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: OrderColors.textMuted,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    height: 1.375,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'ممتاز — آمن للإرسال',
                      style: TextStyle(
                        color: OrderColors.success,
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SvgPicture.string(_Icons.checkCircle, width: 12, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskAlertTile extends StatelessWidget {
  final RiskAlert alert;
  const _RiskAlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isSafe = alert.level == RiskAlertLevel.safe;
    final borderColor = isSafe ? OrderColors.successBorder : OrderColors.warningBorder;
    final bgColor = isSafe ? OrderColors.successBg : OrderColors.warningBg;
    final accent = isSafe ? OrderColors.success : OrderColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SvgPicture.string(
              isSafe ? _Icons.shieldCheckSafe : _Icons.warningTriangle,
              width: 15,
              height: 15,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  alert.title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: accent,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: OrderColors.textMuted,
                    fontFamily: 'Cairo',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final OrderReviewController controller;
  const _ConfirmButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Get.off(
            () => OrderSuccessScreen(
              totalAmount: controller.totalAmount,
              itemCount: controller.products.length,
            ),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 350),
          );
        },
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: OrderColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'تأكيد الطلب ✓',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
    );
  }
}

class _SecondaryActionsRow extends StatelessWidget {
  const _SecondaryActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedPressable(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.offAll(
            () => const HomeScreen(),
            transition: Transition.fadeIn,
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: OrderColors.danger,
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: AnimatedPressable(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Get.snackbar('تعديل', 'عدّل الكميات في قسم المنتجات أعلاه'),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: OrderColors.chipBg,
                border: Border.all(color: OrderColors.cardBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.string(_Icons.pencil('#45556C'), width: 14, height: 14),
                  const SizedBox(width: 6),
                  const Text(
                    'تعديل',
                    style: TextStyle(
                      color: Color(0xFF45556C),
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
