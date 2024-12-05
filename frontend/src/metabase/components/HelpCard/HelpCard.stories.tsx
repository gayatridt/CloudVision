import type { StoryFn } from "@storybook/react";

import HelpCard, { type HelpCardProps } from "./HelpCard";

export default {
  title: "Components/HelpCard",
  component: HelpCard,
};

const Template: StoryFn<HelpCardProps> = args => {
  return <HelpCard {...args} />;
};

export const Default = null;
