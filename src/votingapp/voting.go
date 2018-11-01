package main

import (
	"net/http"

	"github.com/labstack/echo"
)

type votingState struct {
	Votes  map[string]int `json:"votes"`
	Winner string         `json:"winner"`
}

type votingOptions struct {
	Topics []string `json:"topics"`
}

type voteOption struct {
	Topic string `json:"topic"`
}

var (
	state = votingState{make(map[string]int), ""}
)

func getVotes(c echo.Context) error {
	return c.JSON(http.StatusOK, state)
}

func startVoting(c echo.Context) error {
	topics := new(votingOptions)
	if err := c.Bind(topics); err != nil {
		return err
	}

	state = votingState{make(map[string]int), ""}
	for _, val := range topics.Topics {
		state.Votes[val] = 0
	}

	return publishState(c)
}

func vote(c echo.Context) error {
	topic := new(voteOption)
	if err := c.Bind(&topic); err != nil {
		return err
	}

	if state.Winner != "" {
		return c.JSON(http.StatusBadRequest, state)
	}

	state.Votes[topic.Topic] = state.Votes[topic.Topic] + 1
	return publishState(c)
}

func finishVoting(c echo.Context) error {
	winner := getRandomKey(state.Votes)
	for topic, count := range state.Votes {
		if count > state.Votes[winner] {
			winner = topic
		}
	}

	state.Winner = winner
	return publishState(c)
}

func publishState(c echo.Context) error {
	err := sendMessage(state)
	if err != nil {
		return err
	}

	return c.JSON(http.StatusOK, state)
}
