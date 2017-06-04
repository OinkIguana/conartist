'use strict';
import React, { Component } from 'react';
import BarChart from '../../chart/bar-chart';
import { Colors } from '../../constants'

export default class SalesPerType extends Component {
  state: State = {
    metric: 'Customers',
    settings: false,
  };

  get bars() {
    return this.props.records.reduce((p, n) => this.reduceBars(p, n), {});
  }

  reduceBars(bars, record) {
    const updated = { ...bars };
    updated[record.type] = updated[record.type] || 0;
    switch(this.state.metric) {
      case 'Customers':
        ++updated[record.type];
        break;
      case 'Items Sold':
        updated[record.type] += record.products.length;
        break;
      case 'Money':
        updated[record.type] += record.price;
    }
    return updated;
  }

  metricChange(metric) {
    this.setState({ metric });
  }

  render() {
    return (
      <BarChart yLabel={this.state.metric} bars={this.bars} colors={Colors} />
    );
  }
}