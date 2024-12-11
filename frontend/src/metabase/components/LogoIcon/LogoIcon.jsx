import React from "react";
import PropTypes from "prop-types";
import cx from "classnames";

import CS from "metabase/css/core/index.css";
import logo from "../../../../public/images/cloud_vision.png"; 

// DefaultLogoIcon Component
class DefaultLogoIcon extends React.Component {
  // Default properties
  static defaultProps = {
    width: 50, // Default width for the logo
    height: 50, // Default height for the logo
  };

  // Prop types validation
  static propTypes = {
    width: PropTypes.number,
    height: PropTypes.number,
    dark: PropTypes.bool, // Determines the color mode
  };

  render() {
    const { dark, height, width } = this.props;

    return (
      <img
        src={logo} // Logo image source
        alt="Custom Logo"
        className={cx(
          "Icon",
          {
            [CS.textBrand]: !dark, // Apply textBrand class when not in dark mode
            [CS.textWhite]: dark, // Apply textWhite class in dark mode
          }
        )}
        width={width} // Image width
        height= {height} // Image height
        data-testid="main-logo" // Test ID for testing purposes
      />
    );
  }
}

// Main LogoIcon Component
export default function LogoIcon(props) {
  // Ensure PLUGIN_LOGO_ICON_COMPONENTS is defined; use DefaultLogoIcon if not
  const PLUGIN_LOGO_ICON_COMPONENTS =
    window.PLUGIN_LOGO_ICON_COMPONENTS || [];
  const Component = PLUGIN_LOGO_ICON_COMPONENTS[0] || DefaultLogoIcon;

  return <Component {...props} />;
}