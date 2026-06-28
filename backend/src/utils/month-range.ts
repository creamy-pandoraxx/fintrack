export const getMonthDateRange = (month: number, year: number) => {
  const startDate = new Date(Date.UTC(year, month - 1, 1));
  const endDate = new Date(Date.UTC(year, month, 1));

  return { startDate, endDate };
};

export const getExclusiveNextDay = (date: Date) => {
  return new Date(
    Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate() + 1)
  );
};
