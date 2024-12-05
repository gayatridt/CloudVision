import { jt, t } from "ttag";

import HelpCard from "metabase/components/HelpCard";
import ExternalLink from "metabase/core/components/ExternalLink";
import { useSelector } from "metabase/lib/redux";
import { getDocsUrl, getSetting } from "metabase/selectors/settings";

export interface DatabaseHelpCardProps {
  className?: string;
}

export const DatabaseHelpCard = ({
  className,
}: DatabaseHelpCardProps): JSX.Element | null => {
  return null;
};
